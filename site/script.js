document.addEventListener('DOMContentLoaded', function() {
    const tempSlider = document.getElementById('temperature');
    const humSlider = document.getElementById('humidity');
    const tempValue = document.getElementById('tempValue');
    const humValue = document.getElementById('humValue');
    const discomfortIndex = document.getElementById('discomfortIndex');

    const tempDecreaseBtn = document.getElementById('tempDecrease');
    const tempIncreaseBtn = document.getElementById('tempIncrease');
    const humDecreaseBtn = document.getElementById('humDecrease');
    const humIncreaseBtn = document.getElementById('humIncrease');

    function calculateDiscomfortIndex(temp, hum) {
        return 0.81 * temp + 0.01 * hum * (0.99 * temp - 14.3) + 46.3;
    }

    function updateDiscomfortIndex() {
        const temp = parseFloat(tempSlider.value);
        const hum = parseInt(humSlider.value);
        const index = calculateDiscomfortIndex(temp, hum);
        tempValue.textContent = temp.toFixed(1);
        humValue.textContent = hum;
        discomfortIndex.textContent = index.toFixed(2);
    }

    function changeSliderValue(slider, delta) {
        let newValue = parseFloat(slider.value) + delta;
        newValue = Math.max(parseFloat(slider.min), Math.min(parseFloat(slider.max), newValue));
        slider.value = newValue.toFixed(slider.step.includes('.') ? slider.step.split('.')[1].length : 0);
        updateDiscomfortIndex();
    }

    tempSlider.addEventListener('input', updateDiscomfortIndex);
    humSlider.addEventListener('input', updateDiscomfortIndex);

    tempDecreaseBtn.addEventListener('click', () => changeSliderValue(tempSlider, -0.1));
    tempIncreaseBtn.addEventListener('click', () => changeSliderValue(tempSlider, 0.1));
    humDecreaseBtn.addEventListener('click', () => changeSliderValue(humSlider, -1));
    humIncreaseBtn.addEventListener('click', () => changeSliderValue(humSlider, 1));

    // Initialize default values
    updateDiscomfortIndex();
});
