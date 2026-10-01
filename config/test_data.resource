*** Settings ***
Documentation    Prepara la fila indicada por DataDriver antes de ejecutar el negocio.

Library          pytabify.robot.PyTabifyLibrary
Library          FakerLibrary    locale=es_MX


*** Keywords ***
Cargar Datos Del Cliente
    [Documentation]    Obtiene la fila por índice y prepara un usuario ficticio de 20 caracteres.
    [Arguments]    ${row_index}
    ${row_index}=    Convert To Integer    ${row_index}
    ${table}=    Create Data Table From File    ${EXECDIR}/data/tables/customers.csv
    VAR    ${customer}=    ${table}[${row_index}]
    ${customer.username}=    Bothify    text=rf_?????????????????    letters=0123456789abcdef
    RETURN    ${customer}

Cargar Datos De Acceso
    [Documentation]    Obtiene por índice las credenciales y el resultado esperado.
    [Arguments]    ${row_index}
    ${row_index}=    Convert To Integer    ${row_index}
    ${table}=    Create Data Table From File    ${EXECDIR}/data/tables/access_cases.csv
    VAR    ${access}=    ${table}[${row_index}]
    RETURN    ${access}
