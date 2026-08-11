-- supabase_crystal_upgrade.sql
-- Enable uuid-ossp extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Añadir metadatos dinámicos (JSONB) y jerarquía de ubicación a la tabla products
ALTER TABLE public.products
ADD COLUMN IF NOT EXISTS custom_fields JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS location_hierarchy JSONB DEFAULT '{"warehouse": "General", "aisle": "P-01", "shelf": "E-01", "bin": "A"}'::jsonb;

-- 2. Crear tabla para desglose de pagos mixtos y multidivisa por factura
CREATE TABLE IF NOT EXISTS public.transaction_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID REFERENCES public.transactions(id) ON DELETE CASCADE,
    payment_method TEXT NOT NULL,   -- Ej.: 'cash_usd', 'pago_movil_ves', 'pos_ves', 'zelle_usd'
    currency VARCHAR(10) NOT NULL,   -- 'USD', 'VES', 'EUR', etc.
    amount_original NUMERIC(14,2) NOT NULL,
    applied_exchange_rate NUMERIC(12,4) NOT NULL,
    amount_in_base_ves NUMERIC(14,2) NOT NULL,
    reference_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para mejorar el rendimiento de consultas
CREATE INDEX IF NOT EXISTS idx_trans_payments ON public.transaction_payments(transaction_id);
CREATE INDEX IF NOT EXISTS idx_products_custom_fields ON public.products USING gin (custom_fields);
