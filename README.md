# Robot Framework Selenium Testing

Automatización de **ParaBank** con Robot Framework y SeleniumLibrary. Las suites preparan datos y llaman casos de uso completos. Las Pages contienen únicamente clases e instancias de localizadores.

Aplicación: https://parabank.parasoft.com/parabank/

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
    ${customer}=    Cargar Datos Del Cliente    ${row_index}
    Registrar Cliente    ${customer}
    Cerrar Sesión
    Iniciar Sesión    ${customer}
    Consultar Cuentas Del Cliente    ${customer}
    Cerrar Sesión
```

Los auxiliares dentro de los recursos, como `Completar Información Personal`, reducen el detalle técnico del flujo principal y llevan el tag `robot:private`. Robot avisa si se usan desde otro archivo; no es una barrera de acceso de Python.

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
VAR    ${customer}=    ${table}[${row_index}]
${customer.username}=    Bothify    text=rf_?????????????????    letters=0123456789abcdef
```

PyTabify se importa sin alias. FakerLibrary usa `locale=es_MX`; `Bothify` crea el usuario ficticio de 20 caracteres para reducir colisiones en el demo compartido. Los datos personales siguen definidos explícitamente en el CSV. No se buscan identificadores ni se recorren las filas.

Robot permite asignar directamente `${customer.username}`. En PyTabify 3.0, esa asignación prepara el atributo de la fila devuelta; no actualiza el contenido de la tabla ni su CSV. Los casos de uso reciben esa misma fila y acceden a sus atributos, como `${customer.first_name}`. Si se necesita modificar la tabla original, PyTabify ofrece `Set Data Table Value`.

El CSV conserva texto, incluyendo el código postal `01000` y las credenciales vacías. Un índice fuera de rango produce un error de carga.

Para agregar una variación:

1. Añade una fila en `data/tables/customers.csv` o `data/tables/access_cases.csv`.
2. Añade su índice en la matriz correspondiente de `data/test`.
3. Ejecuta la suite; DataDriver genera el caso y PyTabify prepara sus datos. Si reordenas una tabla, actualiza los índices de su matriz.

## Instalación y directorio de ejecución

```bash
git clone https://github.com/angel-valdezzz/robot-framework-selenium-testing.git
cd robot-framework-selenium-testing
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
- `e2e.yml`: ejecución manual con Chrome y artefacto de reportes; selecciona la rama que quieras verificar en **Actions → ParaBank E2E → Run workflow**.

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
