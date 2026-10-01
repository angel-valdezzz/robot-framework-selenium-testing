# Validación de la refactorización

Validada el 1 de octubre de 2026 con Python 3.12 y Robot Framework 7.5.

| Comprobación | Resultado |
| --- | --- |
| Resolución de dependencias con Poetry | Correcta; pytest retirado del proyecto y del lock |
| Robocop | Sin incidencias; formato correcto |
| Robot dry run | 5 casos generados, 5 aprobados |
| Carga de datos y Pages mediante Robot | Aprobada: selección de filas, ceros iniciales, usuario único, credenciales vacías e instancia POM |
| Quality en GitHub Actions | Aprobado en la rama de refactorización |
| E2E con Chrome en GitHub Actions | 5 casos, 5 aprobados, 0 fallidos |

## Evidencia de la rama refactorizada

- [Quality](https://github.com/angel-valdezzz/robot-framework-selenium-testing/actions/runs/36897692254): Robocop y dry run.
- [ParaBank E2E #2](https://github.com/angel-valdezzz/robot-framework-selenium-testing/actions/runs/36897988305): registro, acceso, identidad del cliente, consulta de cuentas, cierre de sesión y rechazo por campos requeridos.

Ambas ejecuciones validan el commit `fd5af6f06d30fc521b5f47da36d4dc413449499c` de `refactor/business-use-cases`. El workflow E2E publica los reportes Robot en el artefacto `parabank-results`, con retención de 7 días.

La comprobación local de preparación de datos se ejecutó con Robot usando un archivo temporal, fuera del repositorio. No se añade una segunda suite de contratos ni un framework de pruebas adicional al proyecto.

## Alcance

La refactorización cambia los nombres de carpetas a `snake_case`, compone casos de uso completos, importa instancias POM declarativas en mayúsculas y prepara los datos con PyTabify desde Robot. Todas las rutas de archivos en Robot se resuelven desde `${EXECDIR}`; se ejecuta desde la raíz del proyecto.

El entorno local de preparación restringe los sockets de Chrome. La comprobación E2E se completó en un runner de GitHub Actions. ParaBank es un demo compartido: su disponibilidad y los reinicios de sus datos pueden afectar ejecuciones futuras.
