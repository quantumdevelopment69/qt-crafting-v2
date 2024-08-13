let currentRecipe = null;
let countdownInterval = null;
let recipes = {};
let InventoryCache = null;
let CurrentIndex = null; 

function populateCraftingBox() {
    const craftingItemsContainer = document.getElementById('crafting-items');
    craftingItemsContainer.innerHTML = '';
    if (recipes[CurrentIndex]) {
        const recipeGroup = recipes[CurrentIndex];
        for (let recipeKey in recipeGroup) {
            const recipe = recipeGroup[recipeKey];
            const itemDiv = document.createElement('div');
            itemDiv.classList.add(
                'bg-gray-700', 'p-2', 'rounded-lg', 'shadow-md', 'flex', 
                'flex-col', 'items-center', 'justify-center', 'text-center', 
                'cursor-pointer', 'hover:bg-gray-600', 'transition-colors', 
                'duration-300', 'h-40', 'w-40', 'overflow-hidden'
            );
            itemDiv.onclick = () => openCraftingDetail(recipeKey);
            itemDiv.innerHTML = `
                <div class="flex flex-col items-center justify-center h-full w-full">
                    <img src="nui://${InventoryCache}/${recipeKey}.png" alt="${recipe.label} Icon" class="drop-shadow-xl h-16 mb-2 object-contain" draggable="false">
                    <p class="text-xl font-semibold text-white mt-2">${recipe.label}</p>
                </div>
            `;
            craftingItemsContainer.appendChild(itemDiv);
        }
    }
}

function openCraftingDetail(recipeKey) {
    const clickSound = document.getElementById('onClick');
    clickSound.volume = 0.3; 
    clickSound.play();

    if (recipes[CurrentIndex] && recipes[CurrentIndex][recipeKey]) {
        currentRecipe = recipes[CurrentIndex][recipeKey];
    } else {
        return;
    }

    document.getElementById('modal-item-name').innerText = currentRecipe.label;
    document.getElementById('modal-item-icon').src = `nui://${InventoryCache}/${recipeKey}.png`;
    document.getElementById('modal-crafting-time').innerText = `Crafting Time: ${currentRecipe.craft_time}s`;

    const ingredientsContainer = document.getElementById('modal-ingredients');
    ingredientsContainer.innerHTML = '';

    currentRecipe.recipe.forEach(ingredient => {
        const ingredientDiv = document.createElement('div');
        ingredientDiv.classList.add('flex', 'items-center', 'gap-2');
        ingredientDiv.innerHTML = `
            <img src="nui://${InventoryCache}/${ingredient.item}.png" alt="${ingredient.label} Icon" class="w-12 h-12 object-contain" draggable="false">
            <p>${ingredient.label} (x${ingredient.amount})</p>
        `;
        ingredientsContainer.appendChild(ingredientDiv);
    });

    document.getElementById('crafting-detail-modal').classList.remove('hidden');
}


function closeDetails() {
    const clickSound = document.getElementById('onClick');
    clickSound.volume = 0.3; 
    clickSound.play();
    document.getElementById('crafting-detail-modal').classList.add('hidden');
}

function startCrafting() {
    closeDetails();

    if (!currentRecipe) {
        return;
    }

    $.post('https://qt-crafting-v2/HasItems', JSON.stringify(currentRecipe), function(canCraft) {
        if (!canCraft) {
            return; 
        }

        const craftingBox = document.getElementById('crafting-box');
        const craftingDetailModal = document.getElementById('crafting-detail-modal');

        craftingBox.classList.add('blurred');
        craftingDetailModal.classList.add('blurred');

        const countdownElement = document.getElementById('crafting-countdown');
        document.getElementById('countdown-item-name').innerText = currentRecipe.label;

        const recipeKey = Object.keys(recipes[CurrentIndex]).find(key => recipes[CurrentIndex][key] === currentRecipe);
        if (recipeKey) {
            document.getElementById('countdown-item-icon').src = `nui://${InventoryCache}/${recipeKey}.png`;
        } else {
            return;
        }

        countdownElement.classList.remove('hidden');

        let remainingTime = currentRecipe.craft_time;
        document.getElementById('countdown-timer').innerText = `${remainingTime}s`;

        countdownInterval = setInterval(() => {
            remainingTime -= 1;
            document.getElementById('countdown-timer').innerText = `${remainingTime}s`;

            if (remainingTime <= 0) {
                clearInterval(countdownInterval);
                countdownElement.classList.add('hidden');
                
                craftingBox.classList.remove('blurred');
                craftingDetailModal.classList.remove('blurred');

                $.post('https://qt-crafting-v2/GiveItem', JSON.stringify({
                    item: recipeKey,
                    amount: currentRecipe.amount,
                    recipe: currentRecipe.recipe
                }));
            }
        }, 1000);
    });
}

window.addEventListener('message', function(event) {
    if (event.data.action === 'SetupHelpOn') {
        document.getElementById('position_helper').classList.remove('hidden');
    } else if (event.data.action === 'SetupHelpOff') {
        document.getElementById('position_helper').classList.add('hidden');
    } else if (event.data.action === 'CraftMenu') {
        recipes = event.data.recipes;  
        openCraftMenu({
            index : event.data.tableIndex,
            title : event.data.TableName,
            inventoryPath : event.data.Inventory
        });
        populateCraftingBox();  
    }
});

function openCraftMenu(data) {
    const craftingBox = document.getElementById('crafting-box');
    craftingBox.classList.remove('hidden');
    craftingBox.classList.add('fade-in');

    document.getElementById('table_name').textContent = data.title.toUpperCase();
    InventoryCache = data.inventoryPath;
    CurrentIndex = data.index;
}

function closeMenu() {
    const clickSound = document.getElementById('onClick');
    clickSound.volume = 0.3; 
    clickSound.play();
    const craftingBox = document.getElementById('crafting-box');
    craftingBox.classList.remove('fade-in');
    craftingBox.classList.add('fade-out');

    const craftingDetailModal = document.getElementById('crafting-detail-modal');
    craftingDetailModal.classList.remove('fade-in');
    craftingDetailModal.classList.add('fade-out');

    setTimeout(() => {
        craftingBox.classList.add('hidden');
        craftingBox.classList.remove('fade-out');

        craftingDetailModal.classList.add('hidden');
        craftingDetailModal.classList.remove('fade-out');

        InventoryCache = null; 
        CurrentIndex = null;
        $.post(`https://qt-crafting-v2/close`, JSON.stringify({}));
    }, 300); 
}
