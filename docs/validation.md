# Validación de la refactorización

Validada el 1 de octubre de 2026 con Python 3.12 y Robot Framework 7.5.

| Comprobación | Resultado |
| --- | --- |
| Resolución de dependencias con Poetry | Correcta; pytest retirado del proyecto y del lock |
| Robocop | Sin incidencias; formato correcto |
| Robot dry run | 5 casos generados, 5 aprobados |
| Carga de datos y Pages mediante Robot | Aprobada: acceso por índice, asignación directa del usuario con Faker, ceros iniciales, credenciales vacías, índice fuera de rango e instancia POM |
| Quality en GitHub Actions | Aprobado en la rama de refactorización |
| E2E con Chrome en GitHub Actions | 5 casos, 5 aprobados, 0 fallidos |

## Evidencia de la rama refactorizada

- [Quality](https://github.com/angel-valdezzz/robotframework-selenium-testing/actions/runs/36899619216): Robocop y dry run.
- [ParaBank E2E #3](https://github.com/angel-valdezzz/robotframework-selenium-testing/actions/runs/36899775522): registro, acceso, identidad del cliente, consulta de cuentas, cierre de sesión y rechazo por campos requeridos.

Ambas ejecuciones validan el commit `ed0c377fbbc6698ff333824a7306d22f5f0aa4f3` de `refactor/business-use-cases`. El workflow E2E publica los reportes Robot en el artefacto `parabank-results`, con retención de 7 días.

La comprobación local de preparación de datos se ejecutó con Robot usando un archivo temporal, fuera del repositorio. No se añade una segunda suite de contratos ni un framework de pruebas adicional al proyecto.

## Alcance

La refactorización cambia los nombres de carpetas a `snake_case`, compone casos de uso completos, importa instancias POM declarativas en mayúsculas y prepara los datos con PyTabify desde Robot, seleccionando filas por índice y generando usuarios con FakerLibrary (`es_MX`). La asignación directa modifica el atributo de la fila usada en el flujo; no reescribe la tabla ni el CSV. Todas las rutas de archivos en Robot se resuelven desde `${EXECDIR}`; se ejecuta desde la raíz del proyecto.

El entorno local de preparación restringe los sockets de Chrome. La comprobación E2E se completó en un runner de GitHub Actions. ParaBank es un demo compartido: su disponibilidad y los reinicios de sus datos pueden afectar ejecuciones futuras.

## Integración de Evidence Reporter

El 1 de octubre de 2026, [ParaBank E2E](https://github.com/angel-valdezzz/robotframework-selenium-testing/actions/runs/36911478133) validó el commit `70ce7447db3fde292ad744c4f486c286c721a37a`:

- Cinco casos con Chrome, cinco aprobados.
- Cinco HTML individuales autocontenidos, generados después de Robot.
- Catorce capturas incrustadas: cuatro por escenario de registro y dos por escenario de rechazo.
- Ninguna advertencia de captura.
- Robocop y dry run aprobados en el workflow Quality.

El artefacto `parabank-results` conserva los JSON, imágenes, reportes técnicos y HTML de negocio. Se inspeccionaron los JSON y HTML descargados para confirmar estados, número de reportes y capturas incrustadas.

La librería se instala desde un commit Git fijo mientras se completa la publicación inicial en PyPI. El navegador de autenticación no respondió durante esa publicación; no se solicitó el token temporal ni se completó la confirmación por correo.

## Instalación desde PyPI

La configuración actual usa Evidence Reporter 0.3.0 desde PyPI e importa `Library    EvidenceReporter`. Ambos workflows instalan con `python -m pip install -r requirements.txt`; Poetry queda como alternativa con el lock actualizado.

La ampliación genera HTML, PDF y DOCX por caso, junto con manifest.json, en el artefacto parabank-results.


## Ampliación de recorridos bancarios

La suite incorpora ocho casos: los cinco anteriores y tres recorridos independientes de registro/cierre, apertura de ahorro y transferencia con comprobación exacta de saldos y movimientos. Robocop y dry-run validan la estructura.

En [la ejecución del PR #7](https://github.com/angel-valdezzz/robotframework-selenium-testing/actions/runs/37418563210), cuatro casos pasaron y cuatro fallaron al cargar el resumen de cuentas después del login, antes de ejecutar las nuevas operaciones bancarias. Se generaron y verificaron ocho reportes HTML/PDF/DOCX y el ZIP. La validación funcional de apertura y transferencias queda pendiente de la recuperación de ParaBank; se mantienen las assertions y los fallos reales.
