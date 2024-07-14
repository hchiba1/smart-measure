document.addEventListener('DOMContentLoaded', function() {
    const tempSlider = document.getElementById('temperature');
    const humSlider = document.getElementById('humidity');
    const tempValue = document.getElementById('tempValue');
    const humValue = document.getElementById('humValue');
    const discomfortIndex = document.getElementById('discomfortIndex');

    function calculateDiscomfortIndex(temp, hum) {
        return 0.81 * temp + 0.01 * hum * (0.99 * temp - 14.3) + 46.3;
    }

    function updateDiscomfortIndex() {
        const temp = parseInt(tempSlider.value);
        const hum = parseInt(humSlider.value);
        const index = calculateDiscomfortIndex(temp, hum);
        tempValue.textContent = temp;
        humValue.textContent = hum;
        discomfortIndex.textContent = index.toFixed(2);
    }

    tempSlider.addEventListener('input', updateDiscomfortIndex);
    humSlider.addEventListener('input', updateDiscomfortIndex);

    // Initialize default values
    updateDiscomfortIndex();
});
