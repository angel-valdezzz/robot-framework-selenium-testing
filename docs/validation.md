# Validación del ejemplo

Validado el 1 de octubre de 2026 con Python 3.12.

| Comprobación | Resultado |
| --- | --- |
| Instalación con Poetry y resolución del lock | Correcta |
| Robocop linter | Sin incidencias |
| Robocop formatter | Formato correcto |
| Robot Framework dry run | 5 casos generados por DataDriver; 5 aprobados |
| Contratos Python | 5 comprobaciones aprobadas |
| Registro por HTTP y mensaje de campos requeridos | Confirmados en el sitio público |
| Localizadores de registro y resumen | Revisados contra HTML y código fuente de ParaBank |
| Quality en GitHub Actions | Aprobado |
| Ejecución Selenium con Chrome en GitHub Actions | 5 casos, 5 aprobados, 0 fallidos |

## Evidencia en GitHub Actions

- [Quality #1](https://github.com/angel-valdezzz/robot-framework-selenium-testing/actions/runs/36890349865): linter, formato, contratos y dry run.
- [ParaBank E2E #1](https://github.com/angel-valdezzz/robot-framework-selenium-testing/actions/runs/36890538858): registro, acceso, consulta de cuentas, cierre de sesión y validaciones de campos requeridos. Ejecutado sobre el commit `6e444a844c207f3521e9eb319c82bc2580e2c662`.

El workflow E2E publica `output.xml`, `log.html`, `report.html` y las capturas disponibles en el artefacto `parabank-results`. Su retención está configurada en 7 días.

## Limitación del entorno local de preparación

El entorno de preparación rechaza `socket()` de Chrome con `Operation not permitted`. Los cinco intentos locales reales fallaron en el setup con `SessionNotCreatedException`; no ejecutaron los pasos del negocio. La validación real se completó después en GitHub Actions, donde Chrome pudo ejecutar los cinco casos correctamente.

ParaBank es un demo compartido. Este resultado verifica la ejecución indicada; la disponibilidad del sitio y los reinicios de sus datos pueden afectar ejecuciones futuras.
