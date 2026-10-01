# Robot Framework Selenium Testing

Ejemplo de automatización de **ParaBank** con Robot Framework y SeleniumLibrary. Las pruebas describen intención de negocio, los localizadores viven en instancias Python y los datos se separan de los escenarios.

Aplicación: https://parabank.parasoft.com/parabank/

## Tecnologías

| Herramienta | Versión declarada | Responsabilidad |
| --- | --- | --- |
| Python | 3.12–3.14 | Variables y preparación de datos |
| Poetry | 2.5.1 recomendado | Entorno y dependencias reproducibles |
| Robot Framework | 7.5.0 | Suites y keywords con estilo BDD |
| SeleniumLibrary | 6.9.0 | Interacción con el navegador |
| DataDriver | 1.11.2 | Un caso ejecutable por fila CSV |
| PyTabify (`pytabify`) | 3.0.0 | Tablas de datos con acceso plano por atributo |
| Robocop | 9.1.0 | Linter y formatter |
| RobotCode | Extensión VS Code | Análisis, ejecución y formato al guardar |

`poetry.lock` fija las dependencias transitivas. No se necesita WebDriverManager: Selenium Manager resuelve el driver. Instala Chrome para la ejecución inicial; Selenium necesita acceso a Internet para descargar el driver cuando corresponde.

## Arquitectura y dependencias

| Carpeta | Contenido | Puede depender de |
| --- | --- | --- |
| `Tests/` | Suites, templates, composición de escenarios BDD | Config, UseCases, DataDriver |
| `Config/` | Variables, navegador y adaptador PyTabify | Librerías externas y Data/Tables |
| `UseCases/` | Flujos y verificaciones de negocio | Pages y keywords de SeleniumLibrary compuestas por Tests |
| `Pages/` | Clases Python e instancias de localizadores | Ninguna capa del proyecto |
| `Data/Test/` | Matriz de ejecución DataDriver | Referencias `customer_id` a las tablas |
| `Data/Tables/` | Datos sintéticos del cliente | Ninguna capa |
| `Checks/` | Contratos de datos y de variables | Config y Pages |

La dirección del código es `Tests → UseCases → Pages`. `Config/bootstrap.resource` es el punto de composición que las suites importan: allí se declaran las librerías, se configuran las sesiones y se cierran los navegadores. UseCases no declara librerías ni administra archivos o navegadores. Pages no importa Selenium, no realiza acciones ni conoce Tests.

Es una arquitectura por capas inspirada en la regla de dependencia hexagonal. **No es una implementación hexagonal estricta**: los casos de uso llaman keywords de SeleniumLibrary directamente para conservar la simplicidad solicitada. Una hexagonal estricta requeriría puertos para esas interacciones.

## POM como variables Python

Cada módulo exporta una instancia mediante `get_variables()`. Robot no recibe la clase como variable:

```python
class LoginPage:
    def __init__(self):
        self.submit = 'css:form[name="login"] input[type="submit"]'

login_page = LoginPage()

def get_variables():
    return {"login_page": login_page}
```

```robotframework
*** Settings ***
Variables    ../Pages/login_page.py

*** Keywords ***
Enviar Solicitud De Acceso
    Click Element    ${login_page.submit}
```

El POM es un repositorio de localizadores. La interacción permanece en Robot y se agrupa en keywords que expresan negocio. Los prefijos `Given`, `When`, `Then`, `And` y `But` son soportados por Robot; no se necesita Cucumber ni una librería BDD adicional.

## Instalación

Desde la raíz del proyecto:

```bash
python -m pip install poetry==2.5.1
poetry install
```

Poetry crea `.venv/` dentro del proyecto. No hace falta activar el entorno si ejecutas mediante `poetry run`.

## Ejecución

```bash
# Todos los escenarios, Chrome sin interfaz por defecto
poetry run robot --outputdir results Tests

# Chrome visible
poetry run robot --variable BROWSER:chrome --outputdir results Tests

# Registro, acceso y cierre de sesión
poetry run robot --include smoke --outputdir results/smoke Tests

# Validaciones de campos requeridos
poetry run robot --include negative --outputdir results/negative Tests

# Otra URL, espera y velocidad
poetry run robot --variable BASE_URL:https://parabank.parasoft.com/parabank/ --variable "TIMEOUT:25 seconds" --variable "SELENIUM_SPEED:0.2 seconds" --outputdir results Tests

# Verificar imports, keywords y generación de casos sin navegador
poetry run robot --dryrun --outputdir results/dryrun Tests

# Contratos de los datos y las instancias POM
poetry run pytest -q
```

Los valores de `--variable` tienen prioridad sobre `Config/settings.py`. `BROWSER_OPTIONS` permite opciones de Selenium cuando tu entorno lo necesita. Por ejemplo, en un contenedor Linux que ejecuta como root:

```bash
poetry run robot --variable 'BROWSER_OPTIONS:add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage")' --outputdir results Tests
```

Este ejemplo de opciones usa quoting de Bash. En una máquina normal, usa el comando de ejecución estándar.

Los resultados están en `results/output.xml`, `results/log.html` y `results/report.html`. SeleniumLibrary adjunta capturas cuando falla una keyword. Se conservan los códigos de salida de Robot para CI.

## Escenarios incluidos

- Dos clientes distintos se registran, cierran sesión, ingresan y consultan su resumen de cuentas.
- Tres combinaciones con usuario, contraseña o ambos vacíos reciben el rechazo esperado.

Cada caso usa una sesión de navegador independiente. El nombre de usuario del registro se genera a partir de UUID y respeta el límite de 20 caracteres de ParaBank; no depende de las credenciales conocidas del demo ni modifica los CSV originales. ParaBank es un entorno compartido: disponibilidad y reinicios del servidor pueden afectar una ejecución real. El proyecto no reinicia ni limpia el banco público.

## DataDriver y PyTabify

DataDriver decide **qué escenarios ejecutar**. Su CSV usa la cabecera `*** Test Cases ***`, columnas `${argumento}`, `[Tags]` y, opcionalmente, `[Documentation]`:

```csv
*** Test Cases ***,${customer_id},[Tags]
Cliente de México,customer_mx,mexico
```

PyTabify carga **los datos del cliente** desde `Data/Tables/customers.csv`. La suite invoca `Preparar Cliente De Prueba`, que busca `customer_id`, comprueba que exista una única fila y devuelve una fila plana con un usuario único.

```robotframework
${customer}=    Preparar Cliente De Prueba    ${customer_id}
When El Cliente Solicita Su Alta En Banca En Línea    ${customer}
Then El Cliente Queda Registrado En Banca En Línea    ${customer}
```

Dentro del flujo se usa `${customer.first_name}`, `${customer.zip_code}` y `${customer.password}`, sin `.value` ni `Evaluate`. Los CSV conservan texto, incluyendo el código postal `01000`.

Para agregar una variación de cliente:

1. Agrega una fila con un `customer_id` único en `Data/Tables/customers.csv`.
2. Agrega ese identificador en `Data/Test/customer_journey.csv`.
3. Ejecuta la suite; DataDriver genera el caso y la infraestructura carga su tabla.

## VS Code: linter y formato al guardar

1. Abre la carpeta raíz del proyecto en VS Code.
2. Instala las extensiones recomendadas por `.vscode/extensions.json`: RobotCode y Python.
3. Ejecuta `poetry install`.
4. Selecciona `.venv` con **RobotCode: Select Python Environment**. En Windows, el ejecutable está en `.venv/Scripts/python.exe`; en Linux/macOS, en `.venv/bin/python`.
5. Guarda un archivo `.robot` o `.resource`.

`.vscode/settings.json` establece RobotCode como formatter, activa `editor.formatOnSave` para Robot Framework y habilita el análisis de Robocop. RobotCode utiliza el formatter de Robocop instalado en el entorno seleccionado. Esta configuración formatea; el autocompletado de keywords y variables lo proporciona RobotCode.

Comandos equivalentes:

```bash
poetry run robocop check Tests UseCases Config
poetry run robocop format Tests UseCases Config
poetry run robocop format --check Tests UseCases Config
```

También hay tareas de VS Code para ejecutar, revisar y formatear. Si guardar no formatea, verifica el entorno seleccionado, el modo de lenguaje **Robot Framework** y que Robocop esté instalado en `.venv`.

## GitHub Actions

- `quality.yml`: linter, comprobación de formato, contratos Python y dry run en push y pull request.
- `e2e.yml`: ejecución manual sobre el sitio público, con reportes y capturas como artefacto descargable. Se activa desde **Actions → ParaBank E2E → Run workflow**.

La ejecución real requiere navegador y acceso a ParaBank. Consulta `docs/validation.md` para conocer qué se verificó durante la preparación del ejemplo.

## Extender los flujos

Para un nuevo flujo, añade los localizadores en Pages, keywords de negocio en UseCases y una suite que importe Config y componga el escenario. Mantén los imports de librerías y la construcción de datos fuera de los flujos. No añadas lógica de Selenium a las clases POM.

## Fuentes

- [Robot Framework User Guide](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)
- [SeleniumLibrary](https://robotframework.org/SeleniumLibrary/SeleniumLibrary.html)
- [DataDriver](https://github.com/Snooz82/robotframework-datadriver)
- [PyTabify](https://github.com/angel-valdezzz/pytabify)
- [Robocop](https://robocop.dev/)
- [RobotCode](https://github.com/robotcodedev/robotcode)
