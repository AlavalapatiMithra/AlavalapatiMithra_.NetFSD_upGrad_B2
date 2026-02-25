
const marks = [82, 75, 65, 54, 91];

const processedMarks = marks.map(mark => Number(mark));


const calculateTotal = (arr) =>
    arr.reduce((sum, mark) => sum + mark, 0);


const calculateAverage = (arr) =>
    arr.length === 0 ? 0 : calculateTotal(arr) / arr.length;


const getResult = (average) =>
    average >= 50 ? "Pass ✅" : "Fail ❌";

const total = calculateTotal(processedMarks);
const average = calculateAverage(processedMarks);
const result = getResult(average);


const outputDiv = document.getElementById("output");

outputDiv.innerHTML = `
    <p><strong>Marks:</strong> ${processedMarks.join(", ")}</p>
    <p><strong>Total Marks:</strong> ${total}</p>
    <p><strong>Average Marks:</strong> ${average.toFixed(2)}</p>
    <p><strong>Result:</strong> ${result}</p>
`;