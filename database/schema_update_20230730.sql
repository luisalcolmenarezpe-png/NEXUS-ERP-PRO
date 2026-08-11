-- 1. Incorporar Metadatos Dinámicos (JSONB) y Ubicación Quirúrgica a Productos
ALTER TABLE public.products
ADD COLUMN IF NOT EXISTS custom_fields JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS location_hierarchy JSONB DEFAULT '{"warehouse": "General", "aisle": "P-01", "shelf": "E-01", "bin": "A"}'::jsonb;

-- 2. Tabla de Desglose de Pagos Mixtos y Multidivisa por Factura
CREATE TABLE IF NOT EXISTS public.transaction_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID REFERENCES public.transactions(id) ON DELETE CASCADE,
    payment_method TEXT NOT NULL,   -- 'cash_usd', 'pago_movil_ves', 'pos_ves', 'zelle_usd'
    currency VARCHAR(10) NOT NULL,   -- 'USD', 'VES', 'EUR'
    amount_original NUMERIC(14, 2) NOT NULL,
    applied_exchange_rate NUMERIC(12, 4) NOT NULL,
    amount_in_base_ves NUMERIC(14, 2) NOT NULL,
    reference_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para consultas relámpago de pagos y metadatos
CREATE INDEX IF NOT EXISTS idx_trans_payments ON public.transaction_payments(transaction_id);
CREATE INDEX IF NOT EXISTS idx_products_custom_fields ON public.products USING gin (custom_fields);
