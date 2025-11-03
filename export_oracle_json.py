import oracledb  # pip install oracledb
import json

# ------------------------------------------
# Conexão Oracle (modo thin, sem Instant Client)
# ------------------------------------------
conn = oracledb.connect(
    user="SEU_USUARIO",
    password="SUA_SENHA",
    dsn="localhost:1521/XEPDB1",  # ajuste para seu DB
    mode=oracledb.DEFAULT_AUTH
)

cur = conn.cursor()

# ==========================================
# Exportar Yards com setores, spots e motos
# ==========================================
cur.execute("""
SELECT y.id, y.name, a.street, a.number_address, a.neighborhood,
       a.city, a.state, a.zip_code, a.country
FROM yards y
JOIN addresses a ON y.address_id = a.id
""")

yards = []
for row in cur.fetchall():
    yard_id, yard_name, street, number, neighborhood, city, state, zip_code, country = row

    # Buscar setores do yard
    cur.execute("""
        SELECT s.id, st.name
        FROM sectors s
        JOIN sector_types st ON s.sector_type_id = st.id
        WHERE s.yard_id = :yard_id
    """, yard_id=yard_id)
    
    sectors = []
    for s_id, s_type in cur.fetchall():
        # Buscar spots de cada setor
        cur.execute("""
            SELECT sp.spot_id, sp.x, sp.y, sp.status, m.id, m.model, m.enginetype, m.plate, m.lastrevisiondate
            FROM spots sp
            LEFT JOIN Motorcycles m ON sp.spot_id = m.spotid
            WHERE sp.sector_id = :sector_id
        """, sector_id=s_id)
        
        spots = []
        for sp_id, x, y, status, m_id, m_model, m_eng, m_plate, m_date in cur.fetchall():
            moto = None
            if m_id:
                moto = {
                    "id": m_id,
                    "model": m_model,
                    "enginetype": m_eng,
                    "plate": m_plate,
                    "last_revision_date": m_date.isoformat() if m_date else None
                }
            spots.append({
                "id": sp_id,
                "x": x,
                "y": y,
                "status": status,
                "motorcycle": moto
            })
        
        sectors.append({
            "id": s_id,
            "type": s_type,
            "spots": spots
        })
    
    yard_obj = {
        "id": yard_id,
        "name": yard_name,
        "address": {
            "street": street,
            "number": number,
            "neighborhood": neighborhood,
            "city": city,
            "state": state,
            "zip_code": zip_code,
            "country": country
        },
        "sectors": sectors
    }
    yards.append(yard_obj)

# Salvar JSON
with open("yards.json", "w", encoding="utf-8") as f:
    json.dump(yards, f, ensure_ascii=False, indent=2)


# ==========================================
# Exportar logs
# ==========================================
cur.execute("""
SELECT id, message, created_at, motorcycle_id, previous_spot_id, destination_spot_id
FROM logs
""")

logs = []
for row in cur.fetchall():
    log_id, message, created_at, moto_id, prev_spot, dest_spot = row
    logs.append({
        "id": log_id,
        "message": message,
        "created_at": created_at.isoformat() if created_at else None,
        "motorcycle_id": moto_id,
        "previous_spot_id": prev_spot,
        "destination_spot_id": dest_spot
    })

with open("logs.json", "w", encoding="utf-8") as f:
    json.dump(logs, f, ensure_ascii=False, indent=2)

cur.close()
conn.close()

print("Exportação concluída! Arquivos 'yards.json' e 'logs.json' gerados.")
