-- ----------------------------
--  Table structure for "public"."actions"
-- ----------------------------

CREATE SEQUENCE actions_action_id_seq START 1;

CREATE TABLE "public"."actions" (
	"action_id" int4 NOT NULL DEFAULT nextval('actions_action_id_seq'::regclass),
	"user_id" varchar(1024),
	"action_name" varchar(1024),
	"source_url" varchar(1024),
	"value_string" varchar(1024),
	"value_timestamp" timestamp(6) NULL,
	"value_integer" int8,
	"value_float" float4,
	"value_interval" interval(6),
	"insert_date" timestamp(6) NULL DEFAULT now()
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."actions" OWNER TO "jason";

-- ----------------------------
--  Primary key structure for table "public"."actions"
-- ----------------------------
ALTER TABLE "public"."actions" ADD CONSTRAINT "actions_pkey" PRIMARY KEY ("action_id") NOT DEFERRABLE INITIALLY IMMEDIATE;

