export const calculateCartTotal = (products) =>
    products
        .map(product => product.price * product.quantity) 
        .reduce((total, value) => total + value, 0);