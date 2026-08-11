-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Tabla de Usuarios y Roles
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('admin', 'cashier', 'auditor', 'manager')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabla de Clientes CRM (con soporte RIF y Límite Crédito)
CREATE TABLE IF NOT EXISTS public.crm_customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rif_cedula VARCHAR(20) UNIQUE NOT NULL,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    credit_limit NUMERIC(12, 2) DEFAULT 0.00,
    current_balance NUMERIC(12, 2) DEFAULT 0.00,
    credit_score INT DEFAULT 50,
    loyalty_points INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabla de Productos e Inventario (Control ABC / Margen SUNDDE)
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    barcode VARCHAR(100) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    unit_cost_usd NUMERIC(12, 4) NOT NULL,
    sale_price_usd NUMERIC(12, 4) NOT NULL,
    tax_rate NUMERIC(5, 2) DEFAULT 16.00, -- IVA 16%
    stock_quantity NUMERIC(12, 2) DEFAULT 0.00,
    reorder_point NUMERIC(12, 2) DEFAULT 5.00,
    expiration_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Tabla de Transacciones Fiscales (Pos/ERP)
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID REFERENCES public.crm_customers(id),
    user_id UUID REFERENCES public.users(id),
    subtotal_ves NUMERIC(14, 2) NOT NULL,
    tax_ves NUMERIC(14, 2) NOT NULL,
    igtf_ves NUMERIC(14, 2) DEFAULT 0.00,
    total_ves NUMERIC(14, 2) NOT NULL,
    exchange_rate_bcv NUMERIC(12, 4) NOT NULL,
    payment_method TEXT NOT NULL,
    terminal_node_id TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Registro de Auditoría Inmutable (Hash Chaining)
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id),
    action TEXT NOT NULL,
    details TEXT NOT NULL,
    previous_hash TEXT NOT NULL,
    current_hash TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Cola de Sincronización Offline Multi-Terminal (CRDT)
CREATE TABLE IF NOT EXISTS public.crdt_sync_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    node_device_id TEXT NOT NULL,
    hlc_timestamp BIGINT NOT NULL,
    payload JSONB NOT NULL,
    is_synced BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices de Rendimiento
CREATE INDEX IF NOT EXISTS idx_products_barcode ON public.products(barcode);
CREATE INDEX IF NOT EXISTS idx_transactions_invoice ON public.transactions(invoice_number);
CREATE INDEX IF NOT EXISTS idx_audit_hash ON public.audit_logs(current_hash);
