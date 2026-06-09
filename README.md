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
#   Version: v2                                                 #
#   Autor: Juan Camilo Villarreal                                #
#   LinkedIn: https://www.linkedin.com/in/juancvillarreal/        #
#                                                               #
#################################################################
============================================================================*/
-->

# RappiPay Fraud Detection Lab — Cortex Agent + Cortex Code

Lab interactivo de 45 minutos donde construyes un agente AI conversacional que responde preguntas sobre fraude de RappiPay en lenguaje natural.

## Que vas a construir

| Componente | Producto Snowflake | Para que sirve |
|-----------|-------------------|----------------|
| Datos sinteticos | Tables + Dynamic Tables | Pipeline de fraude (12K transacciones) |
| Semantic View | Cortex Analyst | Ensena a la AI tu modelo de datos |
| Cortex Agent | Snowflake Intelligence | Chat en lenguaje natural sobre fraude |
| Exploracion | Cortex Code | Generacion de SQL y analisis asistido |

## Prerequisitos

- **Solicita tu cuenta de Snowflake aqui**: [https://go.dataops.live/rappy-day/instructions](https://go.dataops.live/rappy-day/instructions)
- Cortex Code CLI instalado (`npm install -g @snowflake-labs/cortex-code`)

## Como ejecutar (45 min)

1. Ejecuta `scripts/one_click_run.sql` en Snowflake para crear el ambiente
2. Abre el notebook `quickstart_rappipay_cortex_code.ipynb` en Snowflake Notebooks
3. Sigue las 5 Tasks guiadas paso a paso

## Estructura del Lab

| Task | Tiempo | Que haces |
|------|--------|-----------|
| 1. Setup | 10 min | Crear DB + cargar datos sinteticos |
| 2. Explorar con Cortex Code | 10 min | Descubrir patrones de fraude con AI |
| 3. Semantic View | 10 min | Definir el modelo para lenguaje natural |
| 4. Cortex Agent | 10 min | Crear y habilitar el agente en Intelligence |
| 5. Validacion | 5 min | Probar preguntas y cleanup |

## Archivos

| Archivo | Descripcion |
|---------|-------------|
| `quickstart_rappipay_cortex_code.ipynb` | Notebook principal con las 5 Tasks |
| `scripts/one_click_run.sql` | Setup completo (DB, datos, dynamic tables, grants) |
| `requirements.txt` | Dependencias Python |

## Nota

Todos los datos son ficticios pero inspirados en el mercado fintech colombiano/mexicano. No representan transacciones reales de RappiPay.

---
*Autor: Juan Camilo Villarreal | Snowflake SE LATAM*
