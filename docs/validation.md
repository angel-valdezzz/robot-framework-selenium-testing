# Validación del ejemplo

Preparado el 1 de octubre de 2026 con Python 3.12.

| Comprobación | Resultado |
| --- | --- |
| Instalación con Poetry y resolución del lock | Correcta |
| Robocop linter | Sin incidencias |
| Robocop formatter | Archivos formateados |
| Robot Framework dry run | 5 casos generados por DataDriver; 5 aprobados |
| Contratos Python | 5 comprobaciones aprobadas |
| Registro por HTTP y mensaje de campos requeridos | Confirmados en el sitio público |
| Localizadores de registro y resumen | Revisados contra HTML y código fuente de ParaBank |
| Ejecución Selenium contra ParaBank | Bloqueada antes de abrir el navegador |

El entorno de preparación rechaza `socket()` de Chrome con `Operation not permitted`. Los cinco intentos reales fallaron en el setup con `SessionNotCreatedException`; no ejecutaron los pasos del negocio. Un dry run no demuestra que los flujos E2E funcionen contra el sitio.

El workflow manual `e2e.yml` permite verificar los flujos con Chrome en un runner de GitHub Actions. Los resultados de esa ejecución deben revisarse antes de considerar comprobada la suite E2E.
