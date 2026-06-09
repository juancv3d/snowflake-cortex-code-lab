/*============================================================================
################################################################# 
#  ____  _   _  _____        _______ _        _    _  _______   #
# / ___|| \ | |/ _ \ \      / /  ___| |      / \  | |/ / ____|  #
# \___ \|  \| | | | \ \ /\ / /| |_  | |     / _ \ | ' /|  _|    #
#  ___) | |\  | |_| |\ V  V / |  _| | |___ / ___ \| . \| |___   #
#  ____/|_| \_|\___/  \_/\_/  |_|   |_____/_/   \_\_|\_\_____|  #
#################################################################
#                                                               #
#   📅 Fecha: 2026-06-09                                        #
#   🚀 Versión: v1                                              #
#   👤 Autor: Juan Camilo Villarreal                             #
#   🔗 LinkedIn: https://www.linkedin.com/in/juancvillarreal/   #
#                                                               #
# ------------------------------------------------------------- #
#             _ __  __ ____  _  _______ _   _ _____             #
#            | |  \/  |  _ \| |/ / ____| \ | |_   _|            #
#         _  | | |\/| | | | | ' /|  _| |  \| | | |              #
#        | |_| | |  | | |_| | . \| |___| |\  | | |              #
#         \___/|_|  |_|____/|_|\_\_____|_| \_| |_|              #
#                                                               #
#################################################################
============================================================================*/

-- ============================================================================
-- ONE CLICK RUN: RappiPay Fraud Detection Pipeline
-- Descripcion: Setup completo del ambiente, datos sinteticos, dynamic tables,
--              Cortex AI enrichment, semantic views y grants.
-- NOTA: Los datos son ficticios pero inspirados en informacion real del
--       mercado colombiano y mexicano.
-- ============================================================================

-- ============================================================================
-- SECCION 1: ENVIRONMENT SETUP
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- Database y Warehouse
CREATE OR REPLACE DATABASE RAPPIPAY_DB;

CREATE OR REPLACE WAREHOUSE RAPPIPAY_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

USE WAREHOUSE RAPPIPAY_WH;
USE DATABASE RAPPIPAY_DB;

-- Schemas
CREATE OR REPLACE SCHEMA RAPPIPAY_DB.RAW;
CREATE OR REPLACE SCHEMA RAPPIPAY_DB.CURATED;
CREATE OR REPLACE SCHEMA RAPPIPAY_DB.ANALYTICS;
CREATE OR REPLACE SCHEMA RAPPIPAY_DB.APP;

-- Roles custom
CREATE OR REPLACE ROLE RAPPIPAY_DE_ROLE;
CREATE OR REPLACE ROLE RAPPIPAY_ANALYST_ROLE;

-- Asignar roles a usuarios
GRANT ROLE RAPPIPAY_DE_ROLE TO USER jdiaz;
GRANT ROLE RAPPIPAY_DE_ROLE TO USER cursor;
GRANT ROLE RAPPIPAY_ANALYST_ROLE TO USER jdiaz;
GRANT ROLE RAPPIPAY_ANALYST_ROLE TO USER cursor;

-- Grants de database a roles privilegiados
GRANT ALL PRIVILEGES ON DATABASE RAPPIPAY_DB TO ROLE CURSOR_ROLE;
GRANT ALL PRIVILEGES ON DATABASE RAPPIPAY_DB TO ROLE ACCOUNTADMIN;
GRANT ALL PRIVILEGES ON DATABASE RAPPIPAY_DB TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;

-- Grants de warehouse
GRANT USAGE ON WAREHOUSE RAPPIPAY_WH TO ROLE RAPPIPAY_DE_ROLE;
GRANT USAGE ON WAREHOUSE RAPPIPAY_WH TO ROLE RAPPIPAY_ANALYST_ROLE;
GRANT USAGE ON WAREHOUSE RAPPIPAY_WH TO ROLE CURSOR_ROLE;
GRANT USAGE ON WAREHOUSE RAPPIPAY_WH TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;

-- Grants de schemas a roles privilegiados
GRANT ALL PRIVILEGES ON SCHEMA RAPPIPAY_DB.RAW TO ROLE CURSOR_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA RAPPIPAY_DB.CURATED TO ROLE CURSOR_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE CURSOR_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA RAPPIPAY_DB.APP TO ROLE CURSOR_ROLE;

GRANT ALL PRIVILEGES ON SCHEMA RAPPIPAY_DB.RAW TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT ALL PRIVILEGES ON SCHEMA RAPPIPAY_DB.CURATED TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT ALL PRIVILEGES ON SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT ALL PRIVILEGES ON SCHEMA RAPPIPAY_DB.APP TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;

-- Grants de schemas a roles custom
GRANT USAGE ON SCHEMA RAPPIPAY_DB.RAW TO ROLE RAPPIPAY_DE_ROLE;
GRANT USAGE ON SCHEMA RAPPIPAY_DB.CURATED TO ROLE RAPPIPAY_DE_ROLE;
GRANT USAGE ON SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE RAPPIPAY_DE_ROLE;
GRANT USAGE ON SCHEMA RAPPIPAY_DB.APP TO ROLE RAPPIPAY_DE_ROLE;

GRANT USAGE ON SCHEMA RAPPIPAY_DB.RAW TO ROLE RAPPIPAY_ANALYST_ROLE;
GRANT USAGE ON SCHEMA RAPPIPAY_DB.CURATED TO ROLE RAPPIPAY_ANALYST_ROLE;
GRANT USAGE ON SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE RAPPIPAY_ANALYST_ROLE;
GRANT USAGE ON SCHEMA RAPPIPAY_DB.APP TO ROLE RAPPIPAY_ANALYST_ROLE;

-- ============================================================================
-- SECCION 2: RAW TABLES (Bronze Layer)
-- ============================================================================

USE SCHEMA RAPPIPAY_DB.RAW;

CREATE OR REPLACE TABLE RAPPIPAY_DB.RAW.TRANSACTIONS (
    transaction_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(20) NOT NULL,
    merchant_id VARCHAR(20) NOT NULL,
    amount NUMBER(18,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'COP',
    transaction_type VARCHAR(30),
    channel VARCHAR(20),
    device_type VARCHAR(20),
    ip_address VARCHAR(45),
    location_city VARCHAR(50),
    location_country VARCHAR(3),
    status VARCHAR(20),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    description VARCHAR(500)
);

CREATE OR REPLACE TABLE RAPPIPAY_DB.RAW.USERS (
    user_id VARCHAR(20) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    phone VARCHAR(20),
    country VARCHAR(3),
    city VARCHAR(50),
    registration_date DATE,
    kyc_status VARCHAR(20),
    credit_score NUMBER(3),
    risk_level VARCHAR(10),
    verticals_used NUMBER(2),
    total_transactions NUMBER(10),
    account_status VARCHAR(20)
);

CREATE OR REPLACE TABLE RAPPIPAY_DB.RAW.MERCHANTS (
    merchant_id VARCHAR(20) NOT NULL,
    merchant_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    city VARCHAR(50),
    country VARCHAR(3),
    risk_score NUMBER(5,2),
    avg_transaction_amount NUMBER(18,2),
    total_transactions NUMBER(10)
);

CREATE OR REPLACE TABLE RAPPIPAY_DB.RAW.FRAUD_ALERTS (
    alert_id VARCHAR(36) NOT NULL,
    transaction_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(20) NOT NULL,
    alert_type VARCHAR(30),
    severity VARCHAR(10),
    status VARCHAR(20),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    resolved_at TIMESTAMP_NTZ,
    resolution_notes VARCHAR(1000),
    investigator_notes VARCHAR(2000)
);

-- ============================================================================
-- SECCION 3: SYNTHETIC DATA
-- ============================================================================

#IMPORTANTE: Carga los datos antes de continuar

-- Merchants (120 registros)
INSERT INTO RAPPIPAY_DB.RAW.MERCHANTS (merchant_id, merchant_name, category, city, country, risk_score, avg_transaction_amount, total_transactions)
SELECT * FROM (
    SELECT 'MCH-' || LPAD(SEQ4()::VARCHAR, 4, '0') AS merchant_id,
           CASE MOD(SEQ4(), 40)
               WHEN 0 THEN 'Tienda D1' WHEN 1 THEN 'Exito' WHEN 2 THEN 'Oxxo'
               WHEN 3 THEN 'Rappi Restaurantes' WHEN 4 THEN 'Alkosto' WHEN 5 THEN 'Falabella'
               WHEN 6 THEN 'Transmilenio' WHEN 7 THEN 'Uber Colombia' WHEN 8 THEN 'DiDi Mexico'
               WHEN 9 THEN 'Cinepolis' WHEN 10 THEN 'Netflix CO' WHEN 11 THEN 'Spotify'
               WHEN 12 THEN 'Claro Pagos' WHEN 13 THEN 'ETB Telecomunicaciones' WHEN 14 THEN 'EPM Servicios'
               WHEN 15 THEN 'Bancolombia Transferencia' WHEN 16 THEN 'Nequi Transfer' WHEN 17 THEN 'Daviplata Envio'
               WHEN 18 THEN 'Jumbo Supermercado' WHEN 19 THEN 'Carulla Fresh' WHEN 20 THEN 'Soriana'
               WHEN 21 THEN 'Liverpool' WHEN 22 THEN 'Mercado Libre CO' WHEN 23 THEN 'Amazon MX'
               WHEN 24 THEN 'Rappi Travel' WHEN 25 THEN 'Avianca' WHEN 26 THEN 'Volaris'
               WHEN 27 THEN 'Bodytech Gym' WHEN 28 THEN 'Smart Fit' WHEN 29 THEN 'Farmatodo'
               WHEN 30 THEN 'Drogueria Olimpica' WHEN 31 THEN 'Homecenter' WHEN 32 THEN 'Coppel'
               WHEN 33 THEN 'Wom Telecomunicaciones' WHEN 34 THEN 'Tigo Pagos' WHEN 35 THEN 'Movistar Recarga'
               WHEN 36 THEN 'Crepes & Waffles' WHEN 37 THEN 'Frisby' WHEN 38 THEN 'El Corral'
               WHEN 39 THEN 'Dominos Pizza'
           END AS merchant_name,
           CASE MOD(SEQ4(), 6)
               WHEN 0 THEN 'supermercado' WHEN 1 THEN 'restaurante' WHEN 2 THEN 'transporte'
               WHEN 3 THEN 'entretenimiento' WHEN 4 THEN 'pagos_servicios' WHEN 5 THEN 'transferencia'
           END AS category,
           CASE MOD(SEQ4(), 10)
               WHEN 0 THEN 'Bogota' WHEN 1 THEN 'Medellin' WHEN 2 THEN 'Cali'
               WHEN 3 THEN 'Barranquilla' WHEN 4 THEN 'Cartagena' WHEN 5 THEN 'CDMX'
               WHEN 6 THEN 'Guadalajara' WHEN 7 THEN 'Monterrey' WHEN 8 THEN 'Bucaramanga'
               WHEN 9 THEN 'Pereira'
           END AS city,
           CASE WHEN MOD(SEQ4(), 10) >= 5 THEN 'MEX' ELSE 'COL' END AS country,
           ROUND(UNIFORM(10, 95, RANDOM())::NUMBER(5,2), 2) AS risk_score,
           ROUND(UNIFORM(15000, 800000, RANDOM())::NUMBER(18,2), 2) AS avg_transaction_amount,
           UNIFORM(100, 50000, RANDOM()) AS total_transactions
    FROM TABLE(GENERATOR(ROWCOUNT => 120))
);

-- Users (600 registros)
INSERT INTO RAPPIPAY_DB.RAW.USERS (user_id, full_name, email, phone, country, city, registration_date, kyc_status, credit_score, risk_level, verticals_used, total_transactions, account_status)
SELECT * FROM (
    SELECT 'USR-' || LPAD(SEQ4()::VARCHAR, 5, '0') AS user_id,
           CASE MOD(SEQ4(), 30)
               WHEN 0 THEN 'Carlos Andres Martinez' WHEN 1 THEN 'Maria Fernanda Lopez'
               WHEN 2 THEN 'Juan Pablo Hernandez' WHEN 3 THEN 'Laura Valentina Garcia'
               WHEN 4 THEN 'Santiago Ramirez Ortiz' WHEN 5 THEN 'Camila Andrea Torres'
               WHEN 6 THEN 'Andres Felipe Morales' WHEN 7 THEN 'Daniela Alejandra Ruiz'
               WHEN 8 THEN 'Diego Armando Perez' WHEN 9 THEN 'Valentina Sofia Castro'
               WHEN 10 THEN 'Sebastian David Diaz' WHEN 11 THEN 'Isabella Restrepo Mejia'
               WHEN 12 THEN 'Miguel Angel Rodriguez' WHEN 13 THEN 'Natalia Andrea Vargas'
               WHEN 14 THEN 'Alejandro Jose Mendoza' WHEN 15 THEN 'Paula Andrea Gutierrez'
               WHEN 16 THEN 'Fernando Enrique Salazar' WHEN 17 THEN 'Ana Maria Cardenas'
               WHEN 18 THEN 'Roberto Carlos Aguilar' WHEN 19 THEN 'Monica Patricia Rios'
               WHEN 20 THEN 'Oscar Eduardo Pineda' WHEN 21 THEN 'Claudia Milena Bernal'
               WHEN 22 THEN 'Jorge Luis Camacho' WHEN 23 THEN 'Sandra Liliana Parra'
               WHEN 24 THEN 'Pedro Antonio Rojas' WHEN 25 THEN 'Carolina Gomez Uribe'
               WHEN 26 THEN 'Luis Fernando Ochoa' WHEN 27 THEN 'Andrea del Pilar Suarez'
               WHEN 28 THEN 'Cristian Camilo Duarte' WHEN 29 THEN 'Diana Marcela Quintero'
           END AS full_name,
           'user_' || SEQ4() || '@rappi.com' AS email,
           '+57' || LPAD(UNIFORM(3001000000, 3209999999, RANDOM())::VARCHAR, 10, '0') AS phone,
           CASE WHEN MOD(SEQ4(), 5) = 0 THEN 'MEX' ELSE 'COL' END AS country,
           CASE MOD(SEQ4(), 10)
               WHEN 0 THEN 'Bogota' WHEN 1 THEN 'Medellin' WHEN 2 THEN 'Cali'
               WHEN 3 THEN 'Barranquilla' WHEN 4 THEN 'Cartagena' WHEN 5 THEN 'CDMX'
               WHEN 6 THEN 'Guadalajara' WHEN 7 THEN 'Monterrey' WHEN 8 THEN 'Bucaramanga'
               WHEN 9 THEN 'Pereira'
           END AS city,
           DATEADD(DAY, -UNIFORM(30, 1095, RANDOM()), CURRENT_DATE()) AS registration_date,
           CASE MOD(SEQ4(), 4) WHEN 0 THEN 'verified' WHEN 1 THEN 'verified' WHEN 2 THEN 'pending' WHEN 3 THEN 'under_review' END AS kyc_status,
           UNIFORM(300, 850, RANDOM()) AS credit_score,
           CASE WHEN UNIFORM(1, 100, RANDOM()) <= 10 THEN 'high'
                WHEN UNIFORM(1, 100, RANDOM()) <= 35 THEN 'medium'
                ELSE 'low' END AS risk_level,
           UNIFORM(1, 5, RANDOM()) AS verticals_used,
           UNIFORM(5, 2000, RANDOM()) AS total_transactions,
           CASE WHEN UNIFORM(1, 100, RANDOM()) <= 5 THEN 'suspended'
                WHEN UNIFORM(1, 100, RANDOM()) <= 10 THEN 'under_review'
                ELSE 'active' END AS account_status
    FROM TABLE(GENERATOR(ROWCOUNT => 600))
);

-- Transactions (12000 registros)
INSERT INTO RAPPIPAY_DB.RAW.TRANSACTIONS (transaction_id, user_id, merchant_id, amount, currency, transaction_type, channel, device_type, ip_address, location_city, location_country, status, created_at, description)
SELECT * FROM (
    SELECT UUID_STRING() AS transaction_id,
           'USR-' || LPAD(UNIFORM(0, 599, RANDOM())::VARCHAR, 5, '0') AS user_id,
           'MCH-' || LPAD(UNIFORM(0, 119, RANDOM())::VARCHAR, 4, '0') AS merchant_id,
           ROUND(UNIFORM(5000, 5000000, RANDOM())::NUMBER(18,2), 2) AS amount,
           CASE WHEN UNIFORM(1, 5, RANDOM()) = 1 THEN 'MXN' ELSE 'COP' END AS currency,
           CASE MOD(SEQ4(), 6)
               WHEN 0 THEN 'purchase' WHEN 1 THEN 'transfer' WHEN 2 THEN 'withdrawal'
               WHEN 3 THEN 'payment' WHEN 4 THEN 'refund' WHEN 5 THEN 'top_up'
           END AS transaction_type,
           CASE MOD(SEQ4(), 4)
               WHEN 0 THEN 'app_mobile' WHEN 1 THEN 'web' WHEN 2 THEN 'pos_terminal' WHEN 3 THEN 'qr_code'
           END AS channel,
           CASE MOD(SEQ4(), 4)
               WHEN 0 THEN 'android' WHEN 1 THEN 'ios' WHEN 2 THEN 'desktop' WHEN 3 THEN 'tablet'
           END AS device_type,
           CONCAT(UNIFORM(10, 223, RANDOM())::VARCHAR, '.', UNIFORM(0, 255, RANDOM())::VARCHAR, '.', UNIFORM(0, 255, RANDOM())::VARCHAR, '.', UNIFORM(1, 254, RANDOM())::VARCHAR) AS ip_address,
           CASE MOD(SEQ4(), 10)
               WHEN 0 THEN 'Bogota' WHEN 1 THEN 'Medellin' WHEN 2 THEN 'Cali'
               WHEN 3 THEN 'Barranquilla' WHEN 4 THEN 'Cartagena' WHEN 5 THEN 'CDMX'
               WHEN 6 THEN 'Guadalajara' WHEN 7 THEN 'Monterrey' WHEN 8 THEN 'Bucaramanga'
               WHEN 9 THEN 'Pereira'
           END AS location_city,
           CASE WHEN MOD(SEQ4(), 10) >= 5 THEN 'MEX' ELSE 'COL' END AS location_country,
           CASE WHEN UNIFORM(1, 100, RANDOM()) <= 3 THEN 'declined'
                WHEN UNIFORM(1, 100, RANDOM()) <= 8 THEN 'flagged'
                WHEN UNIFORM(1, 100, RANDOM()) <= 12 THEN 'pending_review'
                ELSE 'approved' END AS status,
           DATEADD(MINUTE, -UNIFORM(1, 525600, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
           CASE MOD(SEQ4(), 12)
               WHEN 0 THEN 'Compra en supermercado productos basicos'
               WHEN 1 THEN 'Pago de servicio de transporte urbano'
               WHEN 2 THEN 'Transferencia a cuenta de tercero'
               WHEN 3 THEN 'Pago de factura de servicios publicos'
               WHEN 4 THEN 'Compra en restaurante domicilio'
               WHEN 5 THEN 'Recarga de celular prepago'
               WHEN 6 THEN 'Pago de suscripcion streaming'
               WHEN 7 THEN 'Compra en linea marketplace'
               WHEN 8 THEN 'Retiro de efectivo cajero automatico'
               WHEN 9 THEN 'Pago de cuota de credito'
               WHEN 10 THEN 'Transferencia internacional remesa'
               WHEN 11 THEN 'Compra tiquete de vuelo nacional'
           END AS description
    FROM TABLE(GENERATOR(ROWCOUNT => 12000))
);

-- Fraud Alerts (250 registros)
INSERT INTO RAPPIPAY_DB.RAW.FRAUD_ALERTS (alert_id, transaction_id, user_id, alert_type, severity, status, created_at, resolved_at, resolution_notes, investigator_notes)
SELECT * FROM (
    SELECT UUID_STRING() AS alert_id,
           t.transaction_id,
           t.user_id,
           CASE MOD(SEQ4(), 5)
               WHEN 0 THEN 'identity_theft' WHEN 1 THEN 'card_cloning'
               WHEN 2 THEN 'account_takeover' WHEN 3 THEN 'phishing'
               WHEN 4 THEN 'money_laundering'
           END AS alert_type,
           CASE MOD(SEQ4(), 3)
               WHEN 0 THEN 'critical' WHEN 1 THEN 'high' WHEN 2 THEN 'medium'
           END AS severity,
           CASE MOD(SEQ4(), 4)
               WHEN 0 THEN 'open' WHEN 1 THEN 'investigating'
               WHEN 2 THEN 'resolved_fraud' WHEN 3 THEN 'resolved_false_positive'
           END AS status,
           DATEADD(MINUTE, -UNIFORM(1, 43200, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
           CASE WHEN MOD(SEQ4(), 4) >= 2
                THEN DATEADD(MINUTE, -UNIFORM(1, 10080, RANDOM()), CURRENT_TIMESTAMP())
                ELSE NULL END AS resolved_at,
           CASE MOD(SEQ4(), 5)
               WHEN 0 THEN 'Confirmado como fraude. Usuario reporto transaccion no reconocida. Se bloqueo tarjeta y se inicio proceso de reembolso.'
               WHEN 1 THEN 'Falso positivo. Usuario confirmo la transaccion via llamada telefonica. Patron de compra inusual por viaje.'
               WHEN 2 THEN 'Fraude confirmado por clonacion de tarjeta. Se detecto uso simultaneo en dos ciudades diferentes.'
               WHEN 3 THEN 'Caso escalado a autoridades. Patron consistente con lavado de activos. Multiples transferencias fraccionadas.'
               WHEN 4 THEN 'Resuelto. El usuario fue victima de phishing via SMS. Se restablecieron credenciales y se aplico reembolso parcial.'
           END AS resolution_notes,
           CASE MOD(SEQ4(), 6)
               WHEN 0 THEN 'Transaccion desde IP desconocida en horario inusual (3:42 AM). Dispositivo nuevo no registrado. Monto 4x superior al promedio del usuario.'
               WHEN 1 THEN 'Patron de compras rapidas en multiples merchants en menos de 5 minutos. Geo-localizacion inconsistente entre Bogota y Medellin.'
               WHEN 2 THEN 'Intento de cambio de contrasena seguido de transferencia inmediata al limite maximo. IP asociada a VPN conocida.'
               WHEN 3 THEN 'Serie de microtransacciones (< $10,000 COP) hacia la misma cuenta en intervalos de 2 minutos. Patron tipico de structuring.'
               WHEN 4 THEN 'Usuario reporto no haber realizado la transaccion. Ultima sesion activa hace 72 horas. Posible acceso no autorizado via credential stuffing.'
               WHEN 5 THEN 'Multiples intentos fallidos de autenticacion (7 en 3 minutos) seguidos de transaccion exitosa. Posible brute force en PIN.'
           END AS investigator_notes
    FROM (SELECT transaction_id, user_id, ROW_NUMBER() OVER (ORDER BY RANDOM()) AS rn
          FROM RAPPIPAY_DB.RAW.TRANSACTIONS
          WHERE status IN ('flagged', 'declined', 'pending_review')
          QUALIFY rn <= 250) t
);

-- ============================================================================
-- SECCION 4: DYNAMIC TABLES (Silver Layer - Curated)
-- ============================================================================

USE SCHEMA RAPPIPAY_DB.CURATED;

CREATE OR REPLACE DYNAMIC TABLE RAPPIPAY_DB.CURATED.TRANSACTIONS_ENRICHED
    TARGET_LAG = '1 minute'
    WAREHOUSE = RAPPIPAY_WH
AS
SELECT
    t.transaction_id,
    t.user_id,
    t.merchant_id,
    t.amount,
    t.currency,
    t.transaction_type,
    t.channel,
    t.device_type,
    t.ip_address,
    t.location_city,
    t.location_country,
    t.status,
    t.created_at,
    t.description,
    u.full_name AS user_name,
    u.credit_score AS user_credit_score,
    u.risk_level AS user_risk_level,
    u.kyc_status AS user_kyc_status,
    u.verticals_used AS user_verticals,
    u.account_status AS user_account_status,
    m.merchant_name,
    m.category AS merchant_category,
    m.risk_score AS merchant_risk_score,
    CASE
        WHEN t.amount > 2000000 THEN TRUE
        WHEN u.risk_level = 'high' AND t.amount > 500000 THEN TRUE
        WHEN m.risk_score > 75 THEN TRUE
        WHEN t.status IN ('flagged', 'declined') THEN TRUE
        ELSE FALSE
    END AS is_high_risk,
    CASE
        WHEN t.amount > 3000000 THEN 'critical'
        WHEN t.amount > 1500000 AND u.risk_level IN ('high', 'medium') THEN 'high'
        WHEN m.risk_score > 60 THEN 'medium'
        ELSE 'low'
    END AS computed_risk_level
FROM RAPPIPAY_DB.RAW.TRANSACTIONS t
LEFT JOIN RAPPIPAY_DB.RAW.USERS u ON t.user_id = u.user_id
LEFT JOIN RAPPIPAY_DB.RAW.MERCHANTS m ON t.merchant_id = m.merchant_id;

CREATE OR REPLACE DYNAMIC TABLE RAPPIPAY_DB.CURATED.USER_RISK_PROFILE
    TARGET_LAG = '1 minute'
    WAREHOUSE = RAPPIPAY_WH
AS
SELECT
    u.user_id,
    u.full_name,
    u.country,
    u.city,
    u.credit_score,
    u.risk_level,
    u.kyc_status,
    u.account_status,
    u.registration_date,
    COUNT(t.transaction_id) AS total_transaction_count,
    ROUND(AVG(t.amount), 2) AS avg_transaction_amount,
    ROUND(MAX(t.amount), 2) AS max_transaction_amount,
    COUNT(CASE WHEN t.status = 'flagged' THEN 1 END) AS flagged_count,
    COUNT(CASE WHEN t.status = 'declined' THEN 1 END) AS declined_count,
    ROUND(COUNT(CASE WHEN t.status IN ('flagged', 'declined') THEN 1 END) * 100.0
          / NULLIF(COUNT(t.transaction_id), 0), 2) AS suspicious_rate_pct,
    COUNT(DISTINCT t.merchant_id) AS unique_merchants,
    COUNT(DISTINCT t.location_city) AS unique_cities,
    MAX(t.created_at) AS last_transaction_at,
    DATEDIFF('day', u.registration_date, CURRENT_DATE()) AS account_age_days
FROM RAPPIPAY_DB.RAW.USERS u
LEFT JOIN RAPPIPAY_DB.RAW.TRANSACTIONS t ON u.user_id = t.user_id
GROUP BY u.user_id, u.full_name, u.country, u.city, u.credit_score,
         u.risk_level, u.kyc_status, u.account_status, u.registration_date;

-- ============================================================================
-- SECCION 5: DYNAMIC TABLES (Gold Layer - Analytics)
-- ============================================================================

USE SCHEMA RAPPIPAY_DB.ANALYTICS;

CREATE OR REPLACE DYNAMIC TABLE RAPPIPAY_DB.ANALYTICS.FRAUD_METRICS_HOURLY
    TARGET_LAG = DOWNSTREAM
    WAREHOUSE = RAPPIPAY_WH
AS
SELECT
    DATE_TRUNC('hour', te.created_at) AS hour_bucket,
    COUNT(te.transaction_id) AS total_transactions,
    COUNT(CASE WHEN te.is_high_risk = TRUE THEN 1 END) AS high_risk_transactions,
    ROUND(COUNT(CASE WHEN te.is_high_risk = TRUE THEN 1 END) * 100.0
          / NULLIF(COUNT(te.transaction_id), 0), 2) AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN te.is_high_risk = TRUE THEN te.amount ELSE 0 END), 2) AS amount_at_risk,
    ROUND(AVG(te.amount), 2) AS avg_transaction_amount,
    COUNT(DISTINCT te.user_id) AS unique_users,
    COUNT(DISTINCT te.merchant_id) AS unique_merchants,
    COUNT(CASE WHEN te.computed_risk_level = 'critical' THEN 1 END) AS critical_alerts,
    COUNT(CASE WHEN te.computed_risk_level = 'high' THEN 1 END) AS high_alerts,
    COUNT(CASE WHEN te.computed_risk_level = 'medium' THEN 1 END) AS medium_alerts
FROM RAPPIPAY_DB.CURATED.TRANSACTIONS_ENRICHED te
GROUP BY DATE_TRUNC('hour', te.created_at);

CREATE OR REPLACE DYNAMIC TABLE RAPPIPAY_DB.ANALYTICS.MERCHANT_RISK_SCORECARD
    TARGET_LAG = DOWNSTREAM
    WAREHOUSE = RAPPIPAY_WH
AS
SELECT
    te.merchant_id,
    te.merchant_name,
    te.merchant_category,
    te.merchant_risk_score,
    COUNT(te.transaction_id) AS total_transactions,
    COUNT(CASE WHEN te.is_high_risk = TRUE THEN 1 END) AS flagged_transactions,
    ROUND(COUNT(CASE WHEN te.is_high_risk = TRUE THEN 1 END) * 100.0
          / NULLIF(COUNT(te.transaction_id), 0), 2) AS fraud_association_rate_pct,
    ROUND(SUM(CASE WHEN te.is_high_risk = TRUE THEN te.amount ELSE 0 END), 2) AS total_amount_at_risk,
    ROUND(AVG(te.amount), 2) AS avg_transaction_amount,
    COUNT(DISTINCT te.user_id) AS unique_users,
    RANK() OVER (ORDER BY COUNT(CASE WHEN te.is_high_risk = TRUE THEN 1 END) DESC) AS risk_rank
FROM RAPPIPAY_DB.CURATED.TRANSACTIONS_ENRICHED te
GROUP BY te.merchant_id, te.merchant_name, te.merchant_category, te.merchant_risk_score;

CREATE OR REPLACE DYNAMIC TABLE RAPPIPAY_DB.ANALYTICS.USER_SEGMENTS
    TARGET_LAG = DOWNSTREAM
    WAREHOUSE = RAPPIPAY_WH
AS
SELECT
    urp.user_id,
    urp.full_name,
    urp.country,
    urp.city,
    urp.credit_score,
    urp.risk_level,
    urp.total_transaction_count,
    urp.avg_transaction_amount,
    urp.suspicious_rate_pct,
    urp.account_age_days,
    CASE
        WHEN urp.suspicious_rate_pct > 15 AND urp.risk_level = 'high' THEN 'high_risk_active'
        WHEN urp.suspicious_rate_pct > 10 THEN 'elevated_risk'
        WHEN urp.credit_score > 700 AND urp.total_transaction_count > 100 THEN 'trusted_power_user'
        WHEN urp.total_transaction_count > 50 AND urp.suspicious_rate_pct < 5 THEN 'reliable_regular'
        WHEN urp.account_age_days < 90 THEN 'new_user'
        ELSE 'standard'
    END AS user_segment,
    CASE
        WHEN urp.suspicious_rate_pct > 15 THEN 'enhanced_monitoring'
        WHEN urp.suspicious_rate_pct > 5 THEN 'periodic_review'
        ELSE 'standard_monitoring'
    END AS monitoring_level
FROM RAPPIPAY_DB.CURATED.USER_RISK_PROFILE urp;

-- ============================================================================
-- SECCION 6: CORTEX AI ENRICHMENT
-- ============================================================================

USE SCHEMA RAPPIPAY_DB.ANALYTICS;

CREATE OR REPLACE VIEW RAPPIPAY_DB.ANALYTICS.FRAUD_ALERTS_ENRICHED AS
SELECT
    fa.alert_id,
    fa.transaction_id,
    fa.user_id,
    fa.alert_type,
    fa.severity,
    fa.status,
    fa.created_at,
    fa.resolved_at,
    fa.resolution_notes,
    fa.investigator_notes,
    -- AI Classification: categorizar tipo de fraude basado en la descripcion
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large2',
        'Clasifica la siguiente alerta de fraude en exactamente una de estas categorias: identity_theft, card_cloning, account_takeover, phishing, money_laundering, social_engineering. Solo responde con la categoria sin explicacion adicional. Alerta: ' || COALESCE(fa.investigator_notes, 'Sin notas')
    ) AS ai_fraud_category,
    -- AI Entity Extraction: extraer entidades de las notas del investigador
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large2',
        'Extrae las entidades clave (montos, ciudades, dispositivos, tiempos, metodos) de este texto en formato JSON simple. Texto: ' || COALESCE(fa.investigator_notes, 'Sin notas')
    ) AS ai_extracted_entities,
    -- AI Sentiment: sentimiento de las notas de resolucion
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large2',
        'Analiza el sentimiento de la siguiente nota de resolucion de fraude. Responde solo con: positivo, negativo, o neutro. Nota: ' || COALESCE(fa.resolution_notes, 'Pendiente de resolucion')
    ) AS ai_resolution_sentiment
FROM RAPPIPAY_DB.RAW.FRAUD_ALERTS fa;

-- ============================================================================
-- SECCION 7: SEMANTIC VIEWS
-- ============================================================================

USE SCHEMA RAPPIPAY_DB.ANALYTICS;

CREATE OR REPLACE SEMANTIC VIEW RAPPIPAY_DB.ANALYTICS.SV_TRANSACTIONS
    COMMENT = '{"questions": [
        "Cual es el monto total de transacciones del ultimo mes?",
        "Cuantas transacciones fueron marcadas como fraude hoy?",
        "Cual es la tasa de fraude por ciudad?",
        "Que merchants tienen mas transacciones sospechosas?",
        "What is the average transaction amount by channel?",
        "How many high-risk transactions occurred this week?",
        "Which cities have the highest fraud rate?",
        "Qual e o valor medio das transacoes por categoria?",
        "Quantas transacoes de alto risco ocorreram hoje?",
        "Qual cidade tem a maior taxa de fraude?"
    ]}'
AS
SELECT *
FROM RAPPIPAY_DB.CURATED.TRANSACTIONS_ENRICHED
    COLUMNS (
        transaction_id
            LABEL 'ID de Transaccion'
            SYNONYMS ('id', 'numero transaccion', 'transaction number'),
        user_id
            LABEL 'ID de Usuario'
            SYNONYMS ('usuario', 'cliente', 'user', 'customer'),
        merchant_id
            LABEL 'ID de Merchant'
            SYNONYMS ('comercio', 'tienda', 'store', 'shop'),
        amount
            LABEL 'Monto'
            SYNONYMS ('valor', 'importe', 'cantidad', 'amount', 'value')
            METRIC
                SUM AS total_amount LABEL 'Monto Total' SYNONYMS ('total ventas', 'total sales', 'revenue')
                AVG AS avg_amount LABEL 'Monto Promedio' SYNONYMS ('promedio', 'media', 'average amount'),
        currency
            LABEL 'Moneda'
            SYNONYMS ('divisa', 'currency', 'coin'),
        transaction_type
            LABEL 'Tipo de Transaccion'
            SYNONYMS ('tipo', 'type', 'categoria transaccion'),
        channel
            LABEL 'Canal'
            SYNONYMS ('medio', 'canal de pago', 'payment channel'),
        device_type
            LABEL 'Tipo de Dispositivo'
            SYNONYMS ('dispositivo', 'device', 'equipo'),
        location_city
            LABEL 'Ciudad'
            SYNONYMS ('city', 'ubicacion', 'location', 'ciudad'),
        location_country
            LABEL 'Pais'
            SYNONYMS ('country', 'pais', 'nacion'),
        status
            LABEL 'Estado'
            SYNONYMS ('estatus', 'status', 'estado transaccion'),
        created_at
            LABEL 'Fecha de Creacion'
            SYNONYMS ('fecha', 'date', 'timestamp', 'cuando'),
        merchant_name
            LABEL 'Nombre del Merchant'
            SYNONYMS ('nombre comercio', 'tienda', 'merchant name', 'store name'),
        merchant_category
            LABEL 'Categoria del Merchant'
            SYNONYMS ('categoria', 'rubro', 'category', 'sector'),
        user_risk_level
            LABEL 'Nivel de Riesgo del Usuario'
            SYNONYMS ('riesgo usuario', 'user risk', 'risk level'),
        is_high_risk
            LABEL 'Es Alto Riesgo'
            SYNONYMS ('fraude', 'sospechoso', 'high risk', 'fraud', 'suspicious')
            METRIC
                COUNT AS fraud_transaction_count LABEL 'Conteo de Fraude' SYNONYMS ('total fraudes', 'fraud count'),
        computed_risk_level
            LABEL 'Nivel de Riesgo Calculado'
            SYNONYMS ('riesgo calculado', 'computed risk', 'risk score'),
        transaction_id
            METRIC
                COUNT AS transaction_count LABEL 'Total Transacciones' SYNONYMS ('conteo', 'count', 'total', 'cuantas')
    )
    FILTERS (
        location_country LABEL 'Filtro por Pais' SYNONYMS ('filtrar pais', 'country filter'),
        merchant_category LABEL 'Filtro por Categoria' SYNONYMS ('filtrar categoria', 'category filter'),
        status LABEL 'Filtro por Estado' SYNONYMS ('filtrar estado', 'status filter'),
        is_high_risk LABEL 'Filtro Alto Riesgo' SYNONYMS ('solo fraude', 'only fraud', 'high risk filter'),
        channel LABEL 'Filtro por Canal' SYNONYMS ('filtrar canal', 'channel filter')
    );

CREATE OR REPLACE SEMANTIC VIEW RAPPIPAY_DB.ANALYTICS.SV_FRAUD_ALERTS
    COMMENT = '{"questions": [
        "Cuantas alertas de fraude estan abiertas hoy?",
        "Cual es la distribucion de alertas por severidad?",
        "Cuantos casos de phishing se detectaron este mes?",
        "Cual es el tiempo promedio de resolucion de alertas?",
        "How many critical alerts are unresolved?",
        "What is the distribution of fraud types?",
        "Which alert type has the highest resolution rate?",
        "Quantos alertas criticos estao abertos?",
        "Qual tipo de fraude e mais comum?",
        "Qual e o tempo medio de resolucao?"
    ]}'
AS
SELECT *
FROM RAPPIPAY_DB.RAW.FRAUD_ALERTS
    COLUMNS (
        alert_id
            LABEL 'ID de Alerta'
            SYNONYMS ('alerta', 'alert', 'numero alerta')
            METRIC
                COUNT AS alert_count LABEL 'Total Alertas' SYNONYMS ('conteo alertas', 'alert count', 'cuantas alertas'),
        transaction_id
            LABEL 'ID de Transaccion Asociada'
            SYNONYMS ('transaccion', 'transaction', 'txn'),
        user_id
            LABEL 'ID de Usuario'
            SYNONYMS ('usuario', 'user', 'cliente'),
        alert_type
            LABEL 'Tipo de Alerta'
            SYNONYMS ('tipo fraude', 'fraud type', 'tipo de fraude', 'categoria'),
        severity
            LABEL 'Severidad'
            SYNONYMS ('gravedad', 'severity', 'prioridad', 'urgencia'),
        status
            LABEL 'Estado de la Alerta'
            SYNONYMS ('estado', 'status', 'estatus', 'resolucion'),
        created_at
            LABEL 'Fecha de Creacion'
            SYNONYMS ('fecha alerta', 'alert date', 'cuando', 'fecha'),
        resolved_at
            LABEL 'Fecha de Resolucion'
            SYNONYMS ('fecha resolucion', 'resolution date', 'cuando se resolvio'),
        resolution_notes
            LABEL 'Notas de Resolucion'
            SYNONYMS ('notas', 'comentarios', 'resolution notes', 'notes'),
        investigator_notes
            LABEL 'Notas del Investigador'
            SYNONYMS ('investigacion', 'investigation', 'hallazgos', 'findings')
    )
    FILTERS (
        alert_type LABEL 'Filtro por Tipo' SYNONYMS ('filtrar tipo', 'type filter'),
        severity LABEL 'Filtro por Severidad' SYNONYMS ('filtrar severidad', 'severity filter'),
        status LABEL 'Filtro por Estado' SYNONYMS ('filtrar estado', 'status filter')
    );

-- ============================================================================
-- SECCION 8: GRANTS FINALES
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- Grants completos para SNOWFLAKE_INTELLIGENCE_ADMIN en todos los schemas
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA RAPPIPAY_DB.RAW TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA RAPPIPAY_DB.APP TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;

GRANT ALL PRIVILEGES ON ALL DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT ALL PRIVILEGES ON ALL DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;

GRANT ALL PRIVILEGES ON ALL VIEWS IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;

GRANT SELECT ON ALL SEMANTIC VIEWS IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;

-- Permission to create agents in all schemas
GRANT CREATE CORTEX AGENT ON SCHEMA RAPPIPAY_DB.RAW TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT CREATE CORTEX AGENT ON SCHEMA RAPPIPAY_DB.CURATED TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT CREATE CORTEX AGENT ON SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT CREATE CORTEX AGENT ON SCHEMA RAPPIPAY_DB.APP TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;

-- Grants para CURSOR_ROLE
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA RAPPIPAY_DB.RAW TO ROLE CURSOR_ROLE;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE CURSOR_ROLE;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE CURSOR_ROLE;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA RAPPIPAY_DB.APP TO ROLE CURSOR_ROLE;

GRANT ALL PRIVILEGES ON ALL DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE CURSOR_ROLE;
GRANT ALL PRIVILEGES ON ALL DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE CURSOR_ROLE;

GRANT ALL PRIVILEGES ON ALL VIEWS IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE CURSOR_ROLE;
GRANT SELECT ON ALL SEMANTIC VIEWS IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE CURSOR_ROLE;

-- Grants para roles custom
GRANT SELECT ON ALL TABLES IN SCHEMA RAPPIPAY_DB.RAW TO ROLE RAPPIPAY_DE_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE RAPPIPAY_DE_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE RAPPIPAY_DE_ROLE;
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE RAPPIPAY_DE_ROLE;
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE RAPPIPAY_DE_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE RAPPIPAY_DE_ROLE;

GRANT SELECT ON ALL TABLES IN SCHEMA RAPPIPAY_DB.RAW TO ROLE RAPPIPAY_ANALYST_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE RAPPIPAY_ANALYST_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE RAPPIPAY_ANALYST_ROLE;
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE RAPPIPAY_ANALYST_ROLE;
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE RAPPIPAY_ANALYST_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE RAPPIPAY_ANALYST_ROLE;
GRANT SELECT ON ALL SEMANTIC VIEWS IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE RAPPIPAY_ANALYST_ROLE;

-- Future grants para objetos nuevos
GRANT SELECT ON FUTURE TABLES IN SCHEMA RAPPIPAY_DB.RAW TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT SELECT ON FUTURE TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT SELECT ON FUTURE TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;

GRANT SELECT ON FUTURE TABLES IN SCHEMA RAPPIPAY_DB.RAW TO ROLE CURSOR_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE CURSOR_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE CURSOR_ROLE;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE CURSOR_ROLE;
GRANT SELECT ON FUTURE DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE CURSOR_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE CURSOR_ROLE;

-- Grants de ACCOUNTADMIN (asegurar acceso completo)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA RAPPIPAY_DB.RAW TO ROLE ACCOUNTADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE ACCOUNTADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE ACCOUNTADMIN;
GRANT ALL PRIVILEGES ON ALL DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.CURATED TO ROLE ACCOUNTADMIN;
GRANT ALL PRIVILEGES ON ALL DYNAMIC TABLES IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE ACCOUNTADMIN;
GRANT ALL PRIVILEGES ON ALL VIEWS IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE ACCOUNTADMIN;
GRANT SELECT ON ALL SEMANTIC VIEWS IN SCHEMA RAPPIPAY_DB.ANALYTICS TO ROLE ACCOUNTADMIN;

-- ============================================================================
-- SECCION 9: RESET
-- Descomenta las siguientes lineas para eliminar todos los objetos creados
-- ============================================================================

-- DROP DATABASE IF EXISTS RAPPIPAY_DB;
-- DROP WAREHOUSE IF EXISTS RAPPIPAY_WH;
-- DROP ROLE IF EXISTS RAPPIPAY_DE_ROLE;
-- DROP ROLE IF EXISTS RAPPIPAY_ANALYST_ROLE;
