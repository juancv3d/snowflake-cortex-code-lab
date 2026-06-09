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

# RappiPay — Fraud Detection Quickstart con Cortex Code

Quickstart interactivo que demuestra deteccion de fraude en tiempo real usando Snowflake Dynamic Tables, Cortex AI y una app React generada con Cortex Code.

## Prerequisitos

- Cuenta Snowflake con rol ACCOUNTADMIN (o permisos equivalentes)
- Cortex Code CLI o Desktop instalado
- Node.js 18+ (para la app React)
- Python 3.9+ (para el notebook)

## Como ejecutar

1. Ejecuta `scripts/one_click_run.sql` en Snowflake (crea DB, schemas, tablas, dynamic tables y semantic view)
2. Abre el notebook en Snowflake Notebooks y sigue las secciones guiadas
3. Usa Cortex Code con el prompt de `react_app_prompt.md` para generar el dashboard

## Archivos

| Archivo | Descripcion |
|---------|-------------|
| `scripts/one_click_run.sql` | Setup completo: DB, datos sinteticos, dynamic tables, Cortex AI, semantic view |
| `react_app_prompt.md` | Prompt listo para Cortex Code que genera el dashboard React |
| `requirements.txt` | Dependencias Python para el notebook |
| `README.md` | Este archivo |

## Nota

Todos los datos son ficticios y generados sinteticamente para propositos de demostracion. No representan transacciones reales de RappiPay.
