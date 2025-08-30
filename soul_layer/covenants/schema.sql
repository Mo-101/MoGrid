-- MoStar Grid Database Schema
-- Trinity Lock Protocol with Append-Only Covenant Binding

CREATE TABLE soul_identity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    persona_id TEXT UNIQUE NOT NULL,
    soulprint_hash BYTEA NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE covenant (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    genesis_bundle JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE decision_ledger (
    seq BIGSERIAL PRIMARY KEY,
    decision_id UUID NOT NULL,
    soul_id UUID NOT NULL REFERENCES soul_identity(id),
    covenant_id UUID NOT NULL REFERENCES covenant(id),
    consensus BOOLEAN NOT NULL,
    prev_hash BYTEA,
    entry_hash BYTEA NOT NULL,
    proof JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE outbox_event (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aggregate_type TEXT NOT NULL,
    aggregate_id UUID NOT NULL,
    type TEXT NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    dispatched_at TIMESTAMPTZ
);

INSERT INTO covenant (id, name, genesis_bundle) VALUES (
    'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    'Genesis Covenant',
    '{"version": "1.0", "trinity_lock": true}'
);
