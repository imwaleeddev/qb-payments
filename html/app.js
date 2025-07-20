window.addEventListener('message', function (event) {
    var data = event.data;
    if (data.action === 'Menu') {
        try {
            $('.store>.items').empty();
            for (let i = 0; i < data.Items.length; i++) {
                var item = data.Items[i];
                if (!item) continue;
                $('.store>.items').append(`<div class="item"><div class="nav"><div class="icon-parent add" item="${item.name}" price="${item.price}"><i class="fa fa-plus"></i></div><div class="price-parent">${item.price}$</div></div><img src="${item.img}"><span>${item.label || item.name}</span></div>`);
            }
        } catch (error) {
            console.error(error);
        }
        try {
            SetUpCart(data.Cart);
        } catch (error) {
            console.error(error);
        }
        if ($('body').is(':hidden')) $('body').css('display', 'flex');
    } else if (data.action == 'close') {
        if ($('body').is(':visible')) {
            $('body').fadeOut(100);
        }
    }
});

function SetUpCart(Cart) {
    $('.cart>.items').empty();
    if (Cart.length <= 0) { $('.cart>.totalPayment').html(`<div class="icon-parent"><i class="fa fa-question"></i></div><span>Cart Is Empty</span>`); $('.cart>.items').html(`<i class="fa-solid fa-basket-shopping"></i>`); return; }
    var totalPrice = 0
    for (let i = 0; i < Cart.length; i++) {
        var item = Cart[i];
        if (!item) continue;
        totalPrice = totalPrice + (item.price)
        $('.cart>.items').append(`
        <div class="item">
            <img src="${item.img}">
            <div class="text-parent">
                <span>${item.label || item.name}</span>
                <span>x${item.amount}</span>
            </div>
            <div class="right">
                <div class="icon-parent add" item="${item.name}" price="${item.price}">
                    <i class="fa fa-plus" item="${item.name}" price="${item.price}"></i>
                </div>
                <div class="icon-parent remove" item="${item.name}" price="${item.price}">
                    <i class="fa fa-minus"></i>
                </div>
                <div class="icon-parent trash" item="${item.name}" price="${item.price}">
                    <i class="fa fa-trash"></i>
                </div>
            </div>
        </div>
    `);
        $('.cart>.totalPayment').html(`<div class="icon-parent"><i class="fa-solid fa-money-bill"></i></div><span>Charge For ${(totalPrice).toFixed(2)}$</span>`);
    }
}


$(document).on('click', '.add', function (e) {
    var item = $(this).attr('item');
    var price = $(this).attr('price');
    $.post(`https://${GetParentResourceName()}/add`, JSON.stringify({ item: item, price: price }), function (data) {
        SetUpCart(data);
    });
});

$(document).on('click', '.remove', function (e) {
    var item = $(this).attr('item');
    var price = $(this).attr('price');
    $.post(`https://${GetParentResourceName()}/remove`, JSON.stringify({ item: item, price: price }), function (data) {
        SetUpCart(data);
    });
});

$(document).on('click', '.trash', function (e) {
    var item = $(this).attr('item');
    $.post(`https://${GetParentResourceName()}/trash`, JSON.stringify({ action: 'trash', item: item }), function (data) {
        SetUpCart(data);
    });
});

$(document).on('click', '.totalPayment', function (e) {
    $.post(`https://${GetParentResourceName()}/pay`, JSON.stringify({}), function (data) {
    });
});

$('.items-search').on('input', function (e) {
    var text = $(this).val().toLowerCase();
    $('.item').hide();
    $('.item').filter(function () {
        return $(this).text().toLowerCase().indexOf(text) > -1;
    }).show();
});

$(window).on('keydown', function () {
    switch (event.key) {
        case 'Escape':
            if ($('body').is(':visible')) {
                $('body').fadeOut(75);
                $.post(`https://${GetParentResourceName()}/close`, JSON.stringify());
            }
    }
});
