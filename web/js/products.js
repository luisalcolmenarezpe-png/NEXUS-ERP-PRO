import { listProducts, createProduct, updateProduct, deleteProduct } from './api.js';

export async function renderProducts(container) {
  container.innerHTML = `
    <div class="card">
      <h3>Gestión de Productos e Inventario</h3>
      <div id="productForm">
        <input id="p_name" placeholder="Nombre" />
        <input id="p_sku" placeholder="SKU" />
        <input id="p_price" placeholder="Precio" type="number" />
        <input id="p_stock" placeholder="Stock" type="number" />
        <button id="p_save">Guardar Producto</button>
      </div>
      <div id="productList" style="margin-top:15px;">Cargando...</div>
    </div>
  `;

  document.getElementById('p_save').addEventListener('click', async () => {
    const name = document.getElementById('p_name').value;
    const sku = document.getElementById('p_sku').value;
    const price = parseFloat(document.getElementById('p_price').value || 0);
    const stock = parseInt(document.getElementById('p_stock').value || 0, 10);
    
    await createProduct({ name, sku, price, stock });
    alert('Producto guardado');
    renderProducts(container);
  });
}
