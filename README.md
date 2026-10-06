# Robot Framework Selenium Testing

Automatización de **ParaBank** con Robot Framework y SeleniumLibrary. Las suites preparan datos y llaman casos de uso completos. Las Pages contienen únicamente clases e instancias de localizadores.

Aplicación: https://parabank.parasoft.com/parabank/

## Instalación con pip

```bash
python -m venv .venv
# Activa el entorno: .venv\Scripts\activate en Windows o source .venv/bin/activate en Linux/macOS
python -m pip install -r requirements.txt
robot --outputdir results tests
rf-evidence build results/evidence --output results/business-reports --formats html pdf docx
```

Evidence Reporter se instala desde PyPI con `pip install robotframework-evidence-reporter==0.3.0`. Poetry se conserva como alternativa.

La interfaz de los reportes está en inglés por defecto. Usa `rf-evidence build results/evidence --output results/business-reports-es --formats html pdf docx --language es` para generar la versión en español a partir de las mismas evidencias.

## Tecnologías

| Herramienta | Versión declarada | Responsabilidad |
| --- | --- | --- |
| Python | 3.12–3.14 | Archivos de variables y Pages |
| Poetry | 2.5.1 recomendado | Entorno y dependencias reproducibles |
| Robot Framework | 7.5.0 | Suites, templates y keywords de negocio |
| SeleniumLibrary | 6.9.0 | Interacción con el navegador |
| DataDriver | 1.11.2 | Un caso ejecutable por fila de la matriz CSV |
| PyTabify (`pytabify`) | 3.0.0 | Carga y preparación de tablas desde Robot |
| FakerLibrary | 6.0.0 | Datos ficticios con Faker y locale `es_MX` |
| Evidence Reporter | 0.3.0 | HTML PDF Word y manifiesto de evidencias |
| Marka | 0.1.0 | Highlights, dots numerados, etiquetas y notas para capturas |
| Robocop | 9.1.0 | Linter y formatter |
| RobotCode | Extensión VS Code | Análisis, ejecución y formato al guardar |

`poetry.lock` fija las dependencias transitivas. Selenium Manager resuelve el driver; no se necesita WebDriverManager. Instala Chrome y permite acceso a Internet para descargar el driver cuando corresponda.

## Arquitectura

| Carpeta | Responsabilidad |
| --- | --- |
| `tests/` | Composición de infraestructura, preparación de datos y escenarios DataDriver |
| `use_cases/` | Flujos completos de negocio y verificaciones de su resultado |
| `pages/` | Clases Python declarativas e instancias con localizadores |
| `config/` | Configuración, ciclo de vida del navegador y carga de tablas |
| `data/test/` | Matrices DataDriver: nombre del caso, índice de fila y tags |
| `data/tables/` | Datos de entrada y resultados esperados de cada caso |
| `docs/` | Evidencia y alcance de la validación |

La dependencia es `tests → use_cases → pages`. Las suites importan los recursos de `config` para componer las librerías externas. UseCases no importa librerías ni lee archivos, y Pages no importa Selenium ni ejecuta acciones.

Es una arquitectura por capas inspirada en la regla de dependencia hexagonal. Los casos de uso llaman directamente keywords de SeleniumLibrary para conservar la sintaxis natural de Robot; una hexagonal estricta requeriría puertos para esas interacciones.

## Casos de uso completos

Las keywords públicas expresan operaciones de negocio:

- `Registrar Cliente`: completa el alta y confirma que quedó registrado.
- `Iniciar Sesión`: autentica al cliente y confirma su acceso.
- `Consultar Cuentas Del Cliente`: comprueba la identidad del cliente y la disponibilidad de cuentas.
- `Cerrar Sesión`: termina el acceso y confirma que volvió el formulario de login.
- `Validar Rechazo De Acceso`: solicita acceso con los datos de la fila y confirma el rechazo esperado.

El estilo inspirado en BDD se refleja en los nombres y la intención de negocio. Las suites llaman directamente estas keywords:

```robotframework
Registrar Cliente Y Consultar Sus Cuentas
    [Arguments]    ${row_index}
    ${data_table}=    Cargar Datos Del Cliente    ${row_index}
    Registrar Cliente    ${data_table}
    Cerrar Sesión
    Iniciar Sesión    ${data_table}
    Consultar Cuentas Del Cliente    ${data_table}
    Cerrar Sesión
```

Los auxiliares dentro de los recursos, como `Completar Información Personal`, reducen el detalle técnico del flujo principal y llevan el tag `robot:private`. Robot avisa si se usan desde otro archivo; no es una barrera de acceso de Python.

## Recorridos bancarios adicionales

Tres escenarios independientes amplían la suite a ocho casos: registro y cierre de sesión; registro, acceso y apertura de una cuenta de ahorro; y transferencia entre cuentas con verificación de ambos saldos y movimientos. Marka señala los campos y resultados en las capturas.

Los ocho recorridos pasaron con Chrome en [GitHub Actions](https://github.com/angel-valdezzz/robotframework-selenium-testing/actions/runs/37439421904), tras recuperarse ParaBank. Robocop y dry-run también pasaron; el banco sigue siendo un demo compartido sujeto a interrupciones.

## Pages como variables Python

Los localizadores se declaran como atributos de clase y se accede a ellos a través de una instancia:

```python
class LoginPage:
    username = 'css:form[name="login"] input[name="username"]'
    submit = 'css:form[name="login"] input[type="submit"]'

LOGIN_PAGE = LoginPage()
```

```robotframework
*** Settings ***
Variables    ${EXECDIR}/pages/login_page.py

*** Keywords ***
Enviar Solicitud De Acceso
    Click Element    ${LOGIN_PAGE.submit}
```

No hacen falta decoradores, `__init__`, `get_variables()` ni `__all__` para estas Pages. Las variables importadas usan mayúsculas (`LOGIN_PAGE`, `REGISTRATION_PAGE`, `ACCOUNTS_PAGE`); los atributos y argumentos locales usan `snake_case`.

## Configuración e infraestructura

- `config/settings.py`: URL, navegador, timeout, velocidad y opciones.
- `config/browser.resource`: SeleniumLibrary, apertura y cierre del navegador.
- `config/test_data.resource`: PyTabify, selección de filas por índice y Faker con locale `es_MX`.

La preparación de datos se implementa en Robot usando la librería oficial `pytabify.robot.PyTabifyLibrary`.

## DataDriver y PyTabify

DataDriver decide **qué casos ejecutar**. Su matriz contiene referencias a los datos:

```csv
*** Test Cases ***,${row_index},[Tags]
Cliente de México,0,mexico
```

PyTabify carga **los datos de cada caso** desde `data/tables`. Los índices comienzan en **0** y corresponden al orden de las filas, sin contar la cabecera. La matriz DataDriver pasa `${row_index}`; se convierte a entero antes de acceder a la tabla:

```robotframework
${table}=    Create Data Table From File    ${EXECDIR}/data/tables/customers.csv
VAR    ${data_table}=    ${table}[${row_index}]
${data_table.username}=    Bothify    text=rf_?????????????????    letters=0123456789abcdef
```

PyTabify se importa sin alias. FakerLibrary usa `locale=es_MX`; `Bothify` crea el usuario ficticio de 20 caracteres para reducir colisiones en el demo compartido. Los datos personales siguen definidos explícitamente en el CSV. No se buscan identificadores ni se recorren las filas.

Robot permite asignar directamente `${data_table.username}`. En PyTabify 3.0, esa asignación prepara el atributo de la fila devuelta; no actualiza el contenido de la tabla ni su CSV. Los casos de uso reciben esa misma fila y acceden a sus atributos, como `${data_table.first_name}`. Si se necesita modificar la tabla original, PyTabify ofrece `Set Data Table Value`.

El CSV conserva texto, incluyendo el código postal `01000` y las credenciales vacías. Un índice fuera de rango produce un error de carga.

Para agregar una variación:

1. Añade una fila en `data/tables/customers.csv` o `data/tables/access_cases.csv`.
2. Añade su índice en la matriz correspondiente de `data/test`.
3. Ejecuta la suite; DataDriver genera el caso y PyTabify prepara sus datos. Si reordenas una tabla, actualiza los índices de su matriz.

## Instalación y directorio de ejecución

```bash
git clone https://github.com/angel-valdezzz/robotframework-selenium-testing.git
cd robotframework-selenium-testing
python -m pip install poetry==2.5.1
poetry install
```

Poetry crea `.venv/` dentro del proyecto. Ejecuta los comandos **desde la raíz del proyecto**: los imports de archivos y las rutas de DataDriver y PyTabify usan `${EXECDIR}`.

`${EXECDIR}` es el directorio desde el cual Robot inició la ejecución. No descubre la raíz del repositorio. Ejecutar desde la raíz es una convención explícita de este proyecto, aplicada también en las tareas de VS Code y GitHub Actions.

## Comandos de ejecución

```bash
# Todos los casos, Chrome sin interfaz por defecto
poetry run robot --outputdir results tests

# Chrome visible
poetry run robot --variable BROWSER:chrome --outputdir results tests

# Registro, acceso, consulta de cuentas y cierre
poetry run robot --include smoke --outputdir results/smoke tests

# Validaciones de campos requeridos
poetry run robot --include negative --outputdir results/negative tests

# Otra URL, espera y velocidad
poetry run robot --variable BASE_URL:https://parabank.parasoft.com/parabank/ --variable "TIMEOUT:25 seconds" --variable "SELENIUM_SPEED:0.2 seconds" --outputdir results tests

# Verificar imports, keywords y generación de casos sin navegador
poetry run robot --dryrun --outputdir results/dryrun tests

# Linter y formatter
poetry run robocop check tests use_cases config
poetry run robocop format tests use_cases config
poetry run robocop format --check tests use_cases config
```

Los valores de `--variable` tienen prioridad sobre `config/settings.py`. En un contenedor Linux ejecutado como root se pueden pasar opciones de Chrome (quoting de Bash):

```bash
poetry run robot --variable 'BROWSER_OPTIONS:add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage")' --outputdir results tests
```

Resultados: `results/output.xml`, `results/log.html` y `results/report.html`. SeleniumLibrary adjunta capturas cuando falla una keyword. Los códigos de salida de Robot se conservan para CI.

## Escenarios incluidos

Dos clientes distintos se registran, cierran sesión, ingresan y consultan sus cuentas. Otros tres casos validan usuario vacío, contraseña vacía o ambas credenciales vacías.

Cada caso tiene una sesión de navegador independiente. Los registros usan nombres de usuario aleatorios para evitar depender de cuentas compartidas. ParaBank es un demo público: su disponibilidad y reinicios pueden afectar los resultados. El proyecto no reinicia ni limpia el banco.

## VS Code: Robocop al guardar

1. Abre la raíz del proyecto en VS Code.
2. Instala las extensiones recomendadas: RobotCode y Python.
3. Ejecuta `poetry install`.
4. Selecciona `.venv` con **RobotCode: Select Python Environment**.
5. Guarda un archivo `.robot` o `.resource`.

`.vscode/settings.json` habilita el análisis Robocop, establece RobotCode como formatter y activa `editor.formatOnSave` para Robot Framework. RobotCode usa Robocop instalado en el entorno seleccionado. El formatter ajusta el estilo; RobotCode proporciona el autocompletado.

Las tareas del editor ejecutan Robot y Robocop con `${workspaceFolder}` como directorio de trabajo. Si guardar no formatea, verifica el intérprete, la instalación de Robocop y el modo de lenguaje **Robot Framework**.

## GitHub Actions

- `quality.yml`: Robocop y dry run en push y pull request.
- `e2e.yml`: ejecuta Chrome en push a main, pull requests y manualmente desde **Actions → ParaBank E2E → Run workflow**. Main publica los últimos reportes en Pages; los PR solo validan y adjuntan artefactos.

La validación del proyecto usa Robot Framework y Robocop. Consulta [docs/validation.md](docs/validation.md) para conocer los resultados registrados.

## Fuentes

- [Robot Framework User Guide](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)
- [Robot Framework Style Guide](https://docs.robotframework.org/docs/style_guide)
- [SeleniumLibrary](https://robotframework.org/SeleniumLibrary/SeleniumLibrary.html)
- [DataDriver](https://github.com/Snooz82/robotframework-datadriver)
- [PyTabify](https://github.com/angel-valdezzz/pytabify)
- [Robocop](https://robocop.dev/)
- [RobotCode](https://github.com/robotcodedev/robotcode)
- [FakerLibrary](https://github.com/gunthercox/robotframework-faker)
- [Faker: locale es_MX](https://faker.readthedocs.io/en/master/locales/es_MX.html)

## Reportes individuales de negocio

Las suites importan `config/evidence.resource` y registran evidencias explícitas: página visible y elementos. Los casos de uso conservan sus keywords de negocio. Cada caso recibe `${data_table}`, la fila seleccionada de PyTabify.

```bash
poetry run robot --outputdir results tests
poetry run rf-evidence build results/evidence --output results/business-reports --formats html pdf docx
```

Se genera un HTML autocontenido por caso, con estado final, tiempos, metadatos, hitos opcionales y capturas. Las capturas fallidas advierten por defecto sin cambiar el resultado del caso. El workflow E2E genera los HTML también si Robot falla y los incluye en el artefacto `parabank-results`.

La librería vive en [su repositorio independiente](https://github.com/angel-valdezzz/robotframework-evidence-reporter). La versión 0.3.0 se instala desde [PyPI](https://pypi.org/project/robotframework-evidence-reporter/) usando pip o Poetry. No se copia el código de la librería dentro del framework.

Utiliza una carpeta de resultados nueva por ejecución o elimina los resultados anteriores antes de iniciar: el generador incluye todos los JSON encontrados.

## Marka en las evidencias

Las suites importan `Library    Marka` desde `config/evidence.resource`. El navegador pertenece a SeleniumLibrary; Marka añade anotaciones sobre los elementos y Evidence Reporter captura la página anotada.

```robotframework
Highlight Element    ${REGISTRATION_PAGE.confirmation}    color=coral    group=registration
Add Dot    ${REGISTRATION_PAGE.confirmation}    text=1    position=left    group=registration
Add Label    ${REGISTRATION_PAGE.confirmation}    text=Alta confirmada    position=bottom    group=registration
Add Note    ${ACCOUNTS_PAGE.logout}    text=El cliente ya tiene acceso    position=left    group=registration
TRY
    Capture Page Evidence    Alta confirmada    milestone_id=${milestone}    status=PASS
FINALLY
    Clear Annotations    group=registration
END
```

También se anotan el resumen de cuentas, los rechazos esperados y el cierre de sesión. La captura de página conserva dots y textos que pueden quedar fuera de un recorte de elemento. La limpieza en FINALLY y teardown evita que las marcas se filtren a otra captura o caso.

## Última ejecución publicada

[Abrir últimos reportes](https://angel-valdezzz.github.io/robotframework-selenium-testing/) · [Descargar ZIP](https://angel-valdezzz.github.io/robotframework-selenium-testing/reports.zip)

ParaBank E2E ejecuta las suites en push a main, pull request y ejecución manual. Main publica la fecha, commit, estado de la ejecución y reportes HTML/PDF/Word con las anotaciones de Marka. Si un test falla pero genera evidencia válida, se publica su resultado real, sin convertirlo en PASS.

Pages conserva únicamente la última publicación válida y su ZIP. El artefacto de Actions de main tiene retención de 7 días; los anteriores del mismo workflow se eliminan después de publicar el nuevo. Los PR conservan su artefacto 1 día y no publican. Si no hay reportes válidos, la página anterior sigue disponible. Los reportes no se incorporan al historial Git. Se usan datos ficticios del demo público.
