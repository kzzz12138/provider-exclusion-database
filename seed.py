from datetime import datetime
import pandas as pd
from prisma import Prisma

OUT_DIR = "out"
BATCH = 2000


def to_dt(iso_str):
    return datetime.strptime(str(iso_str), "%Y-%m-%d")


def main():
    db = Prisma()
    db.connect()

    db.exclusionrecord.delete_many()
    db.identifier.delete_many()
    db.excludedparty.delete_many()
    db.importlog.delete_many()
    db.datasource.delete_many()

    # ---------------- data_source ----------------
    src = pd.read_csv(f"{OUT_DIR}/sources.csv", dtype=str)

    source_records = []
    for r in src.itertuples(index=False):
        source_records.append(
            {
                "sourceId": int(r.source_id),
                "sourceName": r.source_name,
                "sourceLevel": r.source_level,
                "fileName": r.file_name,
                "fileType": r.file_type,
                "sourceDate": to_dt(r.source_date),
            }
        )

    db.datasource.create_many(source_records)

    # ---------------- import_log ----------------
    logs = pd.read_csv(f"{OUT_DIR}/import_logs.csv", dtype=str)

    log_records = []
    for r in logs.itertuples(index=False):
        log_records.append({
            "importId": int(r.import_id),
            "sourceId": int(r.source_id),
            "importDate": to_dt(r.import_date),
            "recordsImported": int(r.records_imported),
            "notes": r.notes,
        })

    db.importlog.create_many(data=log_records)

    # ---------------- excluded_party ----------------
    parties = pd.read_csv(OUT_DIR + "/parties.csv", dtype=str,
                          keep_default_na=False)

    party_records = []
    for r in parties.itertuples(index=False):
        party_records.append({
            "partyId": int(r.party_id),
            "partyType": r.party_type,
            "lastName": r.last_name,
            "firstName": r.first_name,
            "middleName": r.middle_name,
            "businessName": r.business_name,
            "dob": to_dt(r.dob),
            "address": r.address,
            "city": r.city,
            "state": r.state,
            "zipCode": r.zip_code,
        })

    for i in range(0, len(party_records), BATCH):
        chunk = party_records[i:i + BATCH]
        db.excludedparty.create_many(data=chunk)
        print("excluded_party:", i + len(chunk), "/", len(party_records))

    # ---------------- identifier ----------------
    idents = pd.read_csv(f"{OUT_DIR}/identifiers.csv", dtype=str)

    identifier_records = []
    for r in idents.itertuples(index=False):
        identifier_records.append({
            "identifierId": int(r.identifier_id),
            "partyId": int(r.party_id),
            "identifierType": r.identifier_type,
            "identifierValue": r.identifier_value,
        })

    for i in range(0, len(identifier_records), BATCH):
        chunk = identifier_records[i:i + BATCH]
        db.identifier.create_many(data=chunk)
        print("identifier:", i + len(chunk), "/", len(identifier_records))

    # ---------------- exclusion_record ----------------
    excl = pd.read_csv(f"{OUT_DIR}/exclusions.csv", dtype=str,
                       keep_default_na=False)

    exclusion_records = []
    for r in excl.itertuples(index=False):
        exclusion_records.append({
            "exclusionId": int(r.exclusion_id),
            "partyId": int(r.party_id),
            "sourceId": int(r.source_id),
            "importId": int(r.import_id),
            "generalCategory": r.general_category,
            "specialty": r.specialty,
            "exclusionType": r.exclusion_type,
            "exclusionDate": to_dt(r.exclusion_date),
            "reinstatementDate": to_dt(r.reinstatement_date),
            "waiverDate": to_dt(r.waiver_date),
            "waiverState": r.waiver_state,
            "status": r.status,
            "recentlyAdded": str(r.recently_added).strip().lower() == "true",
        })

    for i in range(0, len(exclusion_records), BATCH):
        chunk = exclusion_records[i:i + BATCH]
        db.exclusionrecord.create_many(data=chunk)
        print("exclusion_record:", i + len(chunk), "/", len(exclusion_records))

    # ---------------- reset sequences ----------------
    # explicit ids were inserted, so bump each serial sequence past
    # the current max to keep future inserts working
    print("Resetting sequences ...")
    tables = [
        ("data_source", "source_id"),
        ("import_log", "import_id"),
        ("excluded_party", "party_id"),
        ("identifier", "identifier_id"),
        ("exclusion_record", "exclusion_id"),
    ]
    for table, col in tables:
        db.query_raw(
            "SELECT setval(pg_get_serial_sequence('" + table + "', '" + col + "'), "
                                                                              "COALESCE((SELECT MAX(" + col + ") FROM " + table + "), 1))"
        )

    db.disconnect()
    print("Done.")


if __name__ == "__main__":
    main()
