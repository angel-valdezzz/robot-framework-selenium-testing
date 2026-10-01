"""Adaptador de datos: las suites preparan objetos antes del flujo de negocio."""
from pathlib import Path
from uuid import uuid4

from pytabify import DataTableCreator
from robot.api.deco import keyword

ROOT = Path(__file__).resolve().parents[1]
ROBOT_AUTO_KEYWORDS = False


@keyword("Preparar Cliente De Prueba")
def prepare_customer(customer_id: str):
    table = DataTableCreator.from_file(ROOT / "Data" / "Tables" / "customers.csv")
    matches = [row for row in table if row.customer_id == customer_id]
    if len(matches) != 1:
        raise ValueError(f"Se esperaba un cliente único para {customer_id!r}; encontrados: {len(matches)}")
    record = matches[0].to_dict()
    # ParaBank almacena username en VARCHAR(20): prefijo de 3 + 17 hex.
    record["username"] = f"rf_{uuid4().hex[:17]}"
    return DataTableCreator.from_records([record])[0]
