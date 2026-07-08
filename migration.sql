-- CreateTable
CREATE TABLE "data_source" (
    "source_id" SERIAL NOT NULL,
    "source_name" VARCHAR(100) NOT NULL,
    "source_level" VARCHAR(20) NOT NULL,
    "file_name" VARCHAR(255) NOT NULL,
    "file_type" VARCHAR(10) NOT NULL,
    "source_date" DATE NOT NULL,

    CONSTRAINT "data_source_pkey" PRIMARY KEY ("source_id")
);

-- CreateTable
CREATE TABLE "import_log" (
    "import_id" SERIAL NOT NULL,
    "source_id" INTEGER NOT NULL,
    "import_date" DATE NOT NULL,
    "records_imported" INTEGER NOT NULL,
    "notes" VARCHAR(500) NOT NULL DEFAULT '',

    CONSTRAINT "import_log_pkey" PRIMARY KEY ("import_id")
);

-- CreateTable
CREATE TABLE "excluded_party" (
    "party_id" SERIAL NOT NULL,
    "party_type" VARCHAR(12) NOT NULL,
    "last_name" VARCHAR(50) NOT NULL DEFAULT '',
    "first_name" VARCHAR(50) NOT NULL DEFAULT '',
    "middle_name" VARCHAR(100) NOT NULL DEFAULT '',
    "business_name" VARCHAR(100) NOT NULL DEFAULT '',
    "dob" DATE NOT NULL DEFAULT '1900-01-01'::date,
    "address" VARCHAR(60) NOT NULL DEFAULT '',
    "city" VARCHAR(50) NOT NULL DEFAULT '',
    "state" VARCHAR(30) NOT NULL DEFAULT '',
    "zip_code" VARCHAR(10) NOT NULL DEFAULT '',

    CONSTRAINT "excluded_party_pkey" PRIMARY KEY ("party_id")
);

-- CreateTable
CREATE TABLE "identifier" (
    "identifier_id" SERIAL NOT NULL,
    "party_id" INTEGER NOT NULL,
    "identifier_type" VARCHAR(10) NOT NULL,
    "identifier_value" VARCHAR(20) NOT NULL,

    CONSTRAINT "identifier_pkey" PRIMARY KEY ("identifier_id")
);

-- CreateTable
CREATE TABLE "exclusion_record" (
    "exclusion_id" SERIAL NOT NULL,
    "party_id" INTEGER NOT NULL,
    "source_id" INTEGER NOT NULL,
    "import_id" INTEGER NOT NULL,
    "general_category" VARCHAR(50) NOT NULL DEFAULT '',
    "specialty" VARCHAR(50) NOT NULL DEFAULT '',
    "exclusion_type" VARCHAR(20) NOT NULL DEFAULT '',
    "exclusion_date" DATE NOT NULL,
    "reinstatement_date" DATE NOT NULL DEFAULT '1900-01-01'::date,
    "waiver_date" DATE NOT NULL DEFAULT '1900-01-01'::date,
    "waiver_state" VARCHAR(2) NOT NULL DEFAULT '',
    "status" VARCHAR(12) NOT NULL DEFAULT 'ACTIVE',
    "recently_added" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "exclusion_record_pkey" PRIMARY KEY ("exclusion_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "data_source_source_name_source_date_key" ON "data_source"("source_name", "source_date");

-- CreateIndex
CREATE INDEX "import_log_source_id_idx" ON "import_log"("source_id");

-- CreateIndex
CREATE INDEX "excluded_party_last_name_first_name_dob_idx" ON "excluded_party"("last_name", "first_name", "dob");

-- CreateIndex
CREATE INDEX "excluded_party_business_name_idx" ON "excluded_party"("business_name");

-- CreateIndex
CREATE INDEX "identifier_identifier_value_idx" ON "identifier"("identifier_value");

-- CreateIndex
CREATE UNIQUE INDEX "identifier_party_id_identifier_type_identifier_value_key" ON "identifier"("party_id", "identifier_type", "identifier_value");

-- CreateIndex
CREATE INDEX "exclusion_record_party_id_idx" ON "exclusion_record"("party_id");

-- CreateIndex
CREATE INDEX "exclusion_record_source_id_idx" ON "exclusion_record"("source_id");

-- CreateIndex
CREATE INDEX "exclusion_record_exclusion_date_idx" ON "exclusion_record"("exclusion_date");

-- CreateIndex
CREATE INDEX "exclusion_record_exclusion_type_idx" ON "exclusion_record"("exclusion_type");

-- AddForeignKey
ALTER TABLE "import_log" ADD CONSTRAINT "import_log_source_id_fkey" FOREIGN KEY ("source_id") REFERENCES "data_source"("source_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "identifier" ADD CONSTRAINT "identifier_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "excluded_party"("party_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exclusion_record" ADD CONSTRAINT "exclusion_record_party_id_fkey" FOREIGN KEY ("party_id") REFERENCES "excluded_party"("party_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exclusion_record" ADD CONSTRAINT "exclusion_record_source_id_fkey" FOREIGN KEY ("source_id") REFERENCES "data_source"("source_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exclusion_record" ADD CONSTRAINT "exclusion_record_import_id_fkey" FOREIGN KEY ("import_id") REFERENCES "import_log"("import_id") ON DELETE RESTRICT ON UPDATE CASCADE;
