# Dicionário de Dados - Olist Lakehouse

Documentação das 8 tabelas do dataset [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), na camada **Bronze** (`olist_project.bronze`), antes de qualquer transformação.

---

## Diagrama de relacionamento (visão geral)

```
customers ──┐
│
orders ─────┼──── order_items ──── products
│ │ │
│ │ └──── sellers
│ │
└── order_payments
└── order_reviews

geolocation (relaciona via zip_code_prefix, não via FK direta)

```
---

## 1. `customers`

Dados de identificação e localização do cliente.

| Coluna | Tipo | Descrição |
|---|---|---|
| `customer_id` | string | Chave primária — identifica o cliente dentro de um pedido específico |
| `customer_unique_id` | string | Identificador único do cliente entre diferentes pedidos |
| `customer_zip_code_prefix` | int | Prefixo do CEP do cliente (5 primeiros dígitos) |
| `customer_city` | string | Cidade do cliente |
| `customer_state` | string | Estado (UF) do cliente |

> **Nota:** `customer_id` é único por pedido - o mesmo cliente pode ter múltiplos `customer_id` em pedidos diferentes, mas o mesmo `customer_unique_id`.


---


## 2. `orders`

Tabela central: um registro por pedido, com status e timestamps do ciclo de vida.

| Coluna | Tipo | Descrição |
|---|---|---|
| `order_id` | string | Chave primária |
| `customer_id` | string | FK → `customers.customer_id` |
| `order_status` | string | Status do pedido (delivered, shipped, canceled, etc.) |
| `order_purchase_timestamp` | timestamp | Data/hora da compra |
| `order_approved_at` | timestamp | Data/hora da aprovação do pagamento |
| `order_delivered_carrier_date` | timestamp | Data/hora de postagem pela transportadora |
| `order_delivered_customer_date` | timestamp | Data/hora da entrega ao cliente |
| `order_estimated_delivery_date` | timestamp | Data estimada de entrega (prometida) |


---


## 3. `order_items`

Um registro por item dentro de um pedido (um pedido pode ter múltiplos itens).

| Coluna | Tipo | Descrição |
|---|---|---|
| `order_id` | string | FK → `orders.order_id` (parte da chave composta) |
| `order_item_id` | int | Número sequencial do item dentro do pedido (parte da chave composta) |
| `product_id` | string | FK → `products.product_id` |
| `seller_id` | string | FK → `sellers.seller_id` |
| `shipping_limit_date` | timestamp | Prazo limite para envio pelo vendedor |
| `price` | decimal | Preço do item |
| `freight_value` | decimal | Valor do frete daquele item |

> **Chave primária composta:** `(order_id, order_item_id)`


---


## 4. `order_payments`

Forma(s) de pagamento utilizada(s) em cada pedido (um pedido pode ter mais de um método/parcela).

| Coluna | Tipo | Descrição |
|---|---|---|
| `order_id` | string | FK → `orders.order_id` |
| `payment_sequential` | int | Sequência do pagamento (caso haja mais de um método) |
| `payment_type` | string | Tipo de pagamento (credit_card, boleto, voucher, debit_card) |
| `payment_installments` | int | Número de parcelas |
| `payment_value` | decimal | Valor pago |


---


## 5. `order_reviews`

Avaliações deixadas pelos clientes após a entrega.

| Coluna | Tipo | Descrição |
|---|---|---|
| `review_id` | string | Chave primária |
| `order_id` | string | FK → `orders.order_id` |
| `review_score` | int | Nota de 1 a 5 |
| `review_comment_title` | string | Título do comentário (opcional) |
| `review_comment_message` | string | Texto do comentário (opcional) |
| `review_creation_date` | timestamp | Data em que a avaliação foi solicitada |
| `review_answer_timestamp` | timestamp | Data em que o cliente respondeu |


---


## 6. `products`

Catálogo de produtos, com categoria e dimensões físicas.

| Coluna | Tipo | Descrição |
|---|---|---|
| `product_id` | string | Chave primária |
| `product_category_name` | string | Categoria (em português) - FK conceitual → `category_translation` |
| `product_name_lenght` | int | Tamanho do nome do produto (caracteres) |
| `product_description_lenght` | int | Tamanho da descrição (caracteres) |
| `product_photos_qty` | int | Quantidade de fotos do produto |
| `product_weight_g` | int | Peso em gramas |
| `product_length_cm` | int | Comprimento em cm |
| `product_height_cm` | int | Altura em cm |
| `product_width_cm` | int | Largura em cm |

> Nomes de coluna com "lenght" (sem o "g") são um typo do dataset original - mantidos como estão na fonte para rastreabilidade.


---

## 7. `sellers`

Dados de localização dos vendedores.

| Coluna | Tipo | Descrição |
|---|---|---|
| `seller_id` | string | Chave primária |
| `seller_zip_code_prefix` | int | Prefixo do CEP do vendedor |
| `seller_city` | string | Cidade do vendedor |
| `seller_state` | string | Estado (UF) do vendedor |


---


## 8. `geolocation`

Latitude/longitude por prefixo de CEP - não tem FK direta com as outras tabelas, relaciona-se via `zip_code_prefix`.

| Coluna | Tipo | Descrição |
|---|---|---|
| `geolocation_zip_code_prefix` | int | Prefixo do CEP |
| `geolocation_lat` | decimal | Latitude |
| `geolocation_lng` | decimal | Longitude |
| `geolocation_city` | string | Cidade |
| `geolocation_state` | string | Estado (UF) |

> **Atenção:** essa tabela tem múltiplas linhas por prefixo de CEP (várias coordenadas dentro da mesma área). Ao fazer join, considerar deduplicar ou agregar (ex: pegar a primeira ocorrência ou a média de lat/lng) para evitar explosão de linhas.


---


## Tabela adicional: `product_category_name_translation`

Tradução de categoria de produto (PT → EN). Usada como lookup na camada Gold.

| Coluna | Tipo | Descrição |
|---|---|---|
| `product_category_name` | string | Nome da categoria em português (chave de join com `products`) |
| `product_category_name_english` | string | Nome da categoria em inglês |


---


## Relacionamentos principais (resumo)

| De | Para | Tipo de relação |
|---|---|---|
| `orders.customer_id` | `customers.customer_id` | N:1 |
| `order_items.order_id` | `orders.order_id` | N:1 |
| `order_items.product_id` | `products.product_id` | N:1 |
| `order_items.seller_id` | `sellers.seller_id` | N:1 |
| `order_payments.order_id` | `orders.order_id` | N:1 |
| `order_reviews.order_id` | `orders.order_id` | N:1 |
| `products.product_category_name` | `product_category_name_translation.product_category_name` | N:1 |
| `*.zip_code_prefix` | `geolocation.geolocation_zip_code_prefix` | N:N (relação fraca, via CEP) |


---

## Observações de qualidade de dados (a validar na camada Silver)

- `order_items` pode ter múltiplas linhas por `order_id` (1 por item) — não deduplicar por `order_id` sozinho
- `order_payments` pode ter múltiplas linhas por `order_id` (1 por método/parcela de pagamento)
- Campos de data em `orders` podem ser nulos legitimamente (ex: pedido cancelado nunca teve `order_delivered_customer_date`) - não tratar como erro de qualidade
- `geolocation` tem duplicatas por CEP - tratar na modelagem, não na ingestão