*** Settings ***
Documentation    Carga filas con PyTabify y prepara los datos antes de ejecutar el negocio.

Library          Collections
Library          String
Library          pytabify.robot.PyTabifyLibrary    AS    PyTabify


*** Keywords ***
Cargar Datos Del Cliente
    [Documentation]    Selecciona un cliente y asigna un usuario único de hasta 20 caracteres.
    [Arguments]    ${customer_id}
    ${table}    ${index}=    Seleccionar Registro De Tabla
    ...    ${EXECDIR}/data/tables/customers.csv    customer_id    ${customer_id}
    ${suffix}=    Generate Random String    17    0123456789abcdef
    ${table}=    PyTabify.Set Data Table Value    ${table}    ${index}    username    rf_${suffix}
    ${customer}=    PyTabify.Get Data Table Row    ${table}    ${index}
    RETURN    ${customer}

Cargar Datos De Acceso
    [Documentation]    Obtiene la entrada y el resultado esperado de un caso de acceso.
    [Arguments]    ${access_case_id}
    ${table}    ${index}=    Seleccionar Registro De Tabla
    ...    ${EXECDIR}/data/tables/access_cases.csv    access_case_id    ${access_case_id}
    ${access}=    PyTabify.Get Data Table Row    ${table}    ${index}
    RETURN    ${access}

Seleccionar Registro De Tabla
    [Documentation]    Exige una sola coincidencia; devuelve la tabla y el índice de su fila.
    [Tags]    robot:private
    [Arguments]    ${path}    ${key}    ${identifier}
    ${table}=    PyTabify.Create Data Table From File    ${path}
    ${rows}=    PyTabify.Get Data Table Rows    ${table}
    VAR    @{matches}=    @{EMPTY}
    FOR    ${index}    ${row}    IN ENUMERATE    @{rows}
        IF    $row[$key] == $identifier
            Append To List    ${matches}    ${index}
        END
    END
    Length Should Be    ${matches}    1    Se esperaba un registro único para ${identifier} en ${path}.
    RETURN    ${table}    ${matches}[0]
