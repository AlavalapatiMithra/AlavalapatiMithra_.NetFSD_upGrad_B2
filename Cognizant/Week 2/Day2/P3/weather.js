const output = document.getElementById("output");
const buildURL = (lat, lon) =>
    `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current_weather=true`;


const formatWeatherReport = (data) => `
=============================
        WEATHER REPORT
=============================

Temperature : ${data.current_weather.temperature} °C
Wind Speed  : ${data.current_weather.windspeed} km/h
Wind Dir    : ${data.current_weather.winddirection}°
Time        : ${data.current_weather.time}

=============================
`;

window.getWeatherWithPromises = () => {

    const lat = document.getElementById("lat").value;
    const lon = document.getElementById("lon").value;

    fetch(buildURL(lat, lon))
        .then(response => {
            if (!response.ok) {
                throw new Error("Network response was not OK");
            }
            return response.json();
        })
        .then(data => {
            output.textContent = formatWeatherReport(data);
        })
        .catch(error => {
            output.textContent = `Error: ${error.message}`;
        });
};

window.getWeatherAsync = async () => {

    try {

        const lat = document.getElementById("lat").value;
        const lon = document.getElementById("lon").value;

        const response = await fetch(buildURL(lat, lon));

        if (!response.ok) {
            throw new Error("Failed to fetch weather data");
        }

        const data = await response.json();

        output.textContent = formatWeatherReport(data);

    } catch (error) {
        output.textContent = `Error: ${error.message}`;
    }
};