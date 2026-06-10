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
#   Fecha: 2026-06-10                                           #
#   Version: v5                                                 #
#   Autor: Juan Camilo Villarreal                               #
#                                                               #
#################################################################
============================================================================*/
-->

# RappiPay Fraud Detection Lab

## Construye un Cortex Agent con Cortex Code en 45 minutos

Lab hands-on donde construyes un agente AI que responde preguntas sobre fraude de RappiPay en lenguaje natural usando Snowflake Intelligence.

## Que vas a construir

| Componente | Producto Snowflake | Funcion |
|-----------|-------------------|---------|
| Datos sinteticos | Tables | 12K transacciones de fraude fintech |
| Semantic View | Cortex Analyst | Modelo para queries en lenguaje natural |
| Cortex Agent | Intelligence | Chat sobre fraude en espanol |
| Exploracion | Cortex Code | SQL y analisis asistido por AI |

## Prerequisitos

1. **Solicita tu cuenta de Snowflake**: [https://go.dataops.live/rappy-day/instructions](https://go.dataops.live/rappy-day/instructions)
2. **Instala Cortex Code CLI**:

**macOS / Linux / WSL:**
```bash
curl -LsS https://ai.snowflake.com/static/cc-scripts/install.sh | sh
```

**Windows (PowerShell):**
```powershell
irm https://ai.snowflake.com/static/cc-scripts/install.ps1 | iex
```

**Desktop App** (alternativa): [Descargar aqui](https://www.snowflake.com/en/product/snowflake-coco/downloads/)

## Como ejecutar

1. Abre el notebook `quickstart_rappipay_cortex_code.ipynb` en Snowflake Notebooks
2. Ejecuta celda por celda — todo esta auto-contenido (no necesitas archivos externos)
3. Sigue las 5 Tasks guiadas

> **Nota**: El notebook incluye todo el SQL de setup. No necesitas ejecutar nada por separado.

## Estructura del Lab (45 min)

| Task | Tiempo | Que haces |
|------|--------|-----------|
| 1. Setup | 10 min | Crear DB, tablas y cargar 12K+ registros sinteticos |
| 2. Explorar con Cortex Code | 10 min | Descubrir patrones de fraude con prompts de AI |
| 3. Semantic View | 10 min | Crear modelo semantico para lenguaje natural |
| 4. Cortex Agent + Intelligence | 10 min | Crear agente y habilitarlo para chat |
| 5. Validacion | 5 min | Probar preguntas y preparar demo |

## Archivos

| Archivo | Descripcion |
|---------|-------------|
| `quickstart_rappipay_cortex_code.ipynb` | Notebook auto-contenido con las 5 Tasks |
| `scripts/one_click_run.sql` | SQL de referencia (todo esta ya en el notebook) |
| `requirements.txt` | Dependencias Python (referencia) |
| `README.md` | Este archivo |

## Tip para el dia del lab

Cuando Cortex Code pida confirmacion de permisos SQL, selecciona **"Allow any statement in RAPPIPAY_DB"** para continuar sin interrupciones repetidas.

## Nota

Todos los datos son ficticios pero inspirados en el mercado fintech colombiano/mexicano. No representan transacciones reales de RappiPay.

---
*Autor: Juan Camilo Villarreal | Snowflake SE LATAM*
