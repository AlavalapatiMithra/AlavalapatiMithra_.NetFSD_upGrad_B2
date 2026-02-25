import { calculateCartTotal } from './cart.js';
const cartItems = [
    { name: "Laptop", price: 50000, quantity: 1 },
    { name: "Mouse", price: 500, quantity: 2 },
    { name: "Keyboard", price: 1500, quantity: 1 }
];

const totalValue = calculateCartTotal(cartItems);

const invoice = `
==============================
        SHOPPING INVOICE
==============================

${cartItems.map(item => 
`Product: ${item.name}
Price: ₹${item.price}
Quantity: ${item.quantity}
Subtotal: ₹${item.price * item.quantity}
------------------------------`
).join("\n")}

Total Cart Value: ₹${totalValue}

==============================
`;

console.log(invoice);