from fastapi import APIRouter
from typing import Dict, Any

router = APIRouter()

@router.get("/medicines/search")
async def search_medicine(query: str):
    """
    Mock medicine database search for autocomplete UI.
    """
    mock_db = [
        {"id": "m1", "name": "Paracetamol 500mg", "pricePerUnit": 0.50, "type": "Tablet"},
        {"id": "m2", "name": "Amoxicillin 250mg", "pricePerUnit": 1.20, "type": "Capsule"},
        {"id": "m3", "name": "Metformin 500mg", "pricePerUnit": 2.50, "type": "Tablet"},
        {"id": "m4", "name": "Azithromycin 500mg", "pricePerUnit": 3.00, "type": "Tablet"},
        {"id": "m5", "name": "Cetirizine 250mg", "pricePerUnit": 1.50, "type": "Tablet"},
        {"id": "m6", "name": "Ibuprofen 10mg", "pricePerUnit": 0.80, "type": "Tablet"},
        {"id": "m7", "name": "Omeprazole 500mg", "pricePerUnit": 2.10, "type": "Tablet"}
    ]
    
    results = [m for m in mock_db if query.lower() in m["name"].lower()]
    return {"status": "success", "data": results}

@router.post("/save")
async def save_prescription(data: Dict[str, Any]):
    """
    Save the prescription to the database.
    """
    return {
        "status": "success",
        "message": "Prescription saved and sent to pharmacy successfully.",
        "prescription_id": "RX-849201"
    }