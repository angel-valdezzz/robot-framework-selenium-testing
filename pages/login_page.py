"""Localizadores declarativos, sin acciones ni dependencias externas."""


class LoginPage:
    username = 'css:form[name="login"] input[name="username"]'
    password = 'css:form[name="login"] input[name="password"]'
    submit = 'css:form[name="login"] input[type="submit"]'
    error = 'css:#rightPanel p.error'


LOGIN_PAGE = LoginPage()
