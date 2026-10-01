# Validación de la refactorización

Preparada el 1 de octubre de 2026 con Python 3.12 y Robot Framework 7.5.

| Comprobación | Resultado |
| --- | --- |
| Resolución de dependencias con Poetry | Correcta; pytest retirado del proyecto y del lock |
| Robocop | Sin incidencias; formato correcto |
| Robot dry run | 5 casos generados, 5 aprobados |
| Carga de datos y Pages mediante Robot | Aprobada: selección de filas, ceros iniciales, usuario único, credenciales vacías e instancia POM |
| E2E con Chrome en la rama de refactorización | Pendiente de GitHub Actions |

La refactorización cambia los nombres de carpetas a `snake_case`, compone casos de uso completos, importa instancias POM declarativas en mayúsculas y prepara los datos con PyTabify desde Robot. Todas las rutas de archivos en Robot se resuelven desde `${EXECDIR}`; se ejecuta desde la raíz del proyecto.

El entorno local de preparación restringe los sockets de Chrome. Por ello la comprobación E2E se realiza en un runner de GitHub Actions. La validación anterior de main pasó cinco casos sobre el commit `6e444a844c207f3521e9eb319c82bc2580e2c662`; ese resultado no valida por sí solo esta refactorización.
