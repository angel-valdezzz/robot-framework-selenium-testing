"""Comprueba composición y datos sin conectarse al sitio público."""
from pathlib import Path
import csv
import importlib
import pytest
from Config.test_data import prepare_customer

ROOT = Path(__file__).resolve().parents[1]


def test_datadriver_references_resolve_and_preserve_postal_code():
    with (ROOT / "Data/Test/customer_journey.csv").open(newline="", encoding="utf-8") as file:
        records = list(csv.DictReader(file))
    customers = [prepare_customer(row["${customer_id}"]) for row in records]
    assert len(customers) == 2
    assert customers[0].zip_code == "01000"
    assert customers[0].username != prepare_customer("customer_mx").username
    assert all(customer.password and customer.first_name for customer in customers)
    assert all(len(customer.username) <= 20 for customer in customers)


def test_unknown_customer_fails_before_browser_actions():
    with pytest.raises(ValueError, match="cliente único"):
        prepare_customer("missing")


@pytest.mark.parametrize("name", ["login_page", "registration_page", "accounts_page"])
def test_pages_export_only_the_instance(name):
    variables = importlib.import_module(f"Pages.{name}").get_variables()
    assert set(variables) == {name}
    assert not isinstance(variables[name], type)
    assert all(isinstance(value, str) for value in vars(variables[name]).values())
