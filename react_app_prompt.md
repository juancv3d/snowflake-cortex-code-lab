<!--
/*============================================================================
################################################################# 
#  ____  _   _  _____        _______ _        _    _  _______   #
# / ___|| \ | |/ _ \ \      / /  ___| |      / \  | |/ / ____|  #
# \___ \|  \| | | | \ \ /\ / /| |_  | |     / _ \ | ' /|  _|    #
#  ___) | |\  | |_| |\ V  V / |  _| | |___ / ___ \| . \| |___   #
#  ____/|_| \_|\___/  \_/\_/  |_|   |_____/_/   \_\_|\_\_____|  #
#################################################################
#                                                               #
#   Fecha: 2026-06-09                                           #
#   Version: v1                                                 #
#   Autor: Juan Camilo Villarreal                                #
#   LinkedIn: https://www.linkedin.com/in/juancvillarreal/        #
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
-->

# Prompt para Cortex Code — Fraud Monitor Dashboard (RappiPay)

## Instrucciones

Copia y pega el siguiente prompt en Cortex Code (CLI o Desktop) para generar la aplicacion React de monitoreo de fraude.

---

## Prompt

Crea una aplicacion React de monitoreo de fraude para RappiPay con las siguientes especificaciones:

### Datos

Conecta a Snowflake database RAPPIPAY_DB con las siguientes tablas:

- `RAPPIPAY_DB.ANALYTICS.FRAUD_METRICS_HOURLY` — metricas agregadas por hora
- `RAPPIPAY_DB.ANALYTICS.FRAUD_ALERTS_ENRICHED` — alertas con clasificacion AI
- `RAPPIPAY_DB.CURATED.TRANSACTIONS_ENRICHED` — transacciones con datos de usuario y merchant
- `RAPPIPAY_DB.ANALYTICS.USER_SEGMENTS` — segmentacion de usuarios por riesgo

### UI Components

1. **Header**: Logo RappiPay, color primario naranja (#FF6B00), indicador de conexion a Snowflake
2. **KPI Cards** (4 cards en fila):
   - Total transacciones hoy
   - Alertas activas (severity HIGH + CRITICAL)
   - Tasa de fraude (%) — ultimas 24h
   - Monto total en riesgo (COP formateado con separador de miles)
3. **Trend Chart**: Grafico de linea (Recharts) con alertas por hora, ultimas 24h, colores por severidad
4. **Alert Table**: Tabla interactiva con columnas: ID, Tipo Fraude, Severidad, Merchant, Monto, Hora. Filtrable y ordenable.
5. **Detail Panel**: Al hacer click en una alerta, mostrar panel lateral con:
   - Datos de la transaccion
   - Perfil del usuario (risk_level, credit_score, kyc_status)
   - Merchant info (category, risk_score)
   - Clasificacion AI (output de AI_CLASSIFY)
   - Sentimiento de notas (output de AI_SENTIMENT)
6. **Filtros globales**: Rango de fecha, tipo de fraude (dropdown), categoria merchant (dropdown), monto minimo (slider)

### Stack Tecnico

- React 18+ con Vite
- Tailwind CSS para estilos
- Recharts para graficos
- Zustand para estado global
- React Query para fetching
- Snowflake connector via API REST

### Diseno

- Theme oscuro por defecto (background #1a1a2e, cards #16213e)
- Accent color: naranja RappiPay (#FF6B00)
- Fuente: Inter
- Responsive (mobile-first)
- Animaciones suaves en transiciones

---

## Despues de generar

1. Revisa los componentes generados
2. Verifica la conexion a Snowflake
3. Ejecuta `npm install && npm run dev`
4. Personaliza segun necesidades del equipo
