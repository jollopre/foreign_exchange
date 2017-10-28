$(function(){
	var form = $('form[data-ref="exchange-rates#index"]');
	var atSuccess = $('[data-ref="exchange-rates#at-success"]');
	var atError = $('[data-ref="exchange-rates#at-error"]');
	var toggleWarning = function(result, jQueryObj) {
		jQueryObj.closest('.form-group')[result ? 'removeClass' : 'addClass']('has-warning');
	};
	var toggleHelp = function(result, jQueryObj) {
		jQueryObj[result ? 'hide' : 'show']();
	};
	var isDate = function(jQueryObj){
		toggleWarning(true, jQueryObj);
		return true;
	};
	var isGreaterThanZero = function(jQueryObj){
		var toNumber = function(jQueryObj) {
			return Number(jQueryObj.val());
		};
		var isNumber = function(jQueryObj) {
			return !Number.isNaN(toNumber(jQueryObj));
		};
		var r = false;
		if (isNumber(jQueryObj)) {
			r = toNumber(jQueryObj) > 0;
		}
		toggleWarning(r, jQueryObj);
		toggleHelp(r, jQueryObj.next());
		return r;	
	};
	var isNotEmpty = function(jQueryObj) {
		var r = jQueryObj.val() !== '';
		toggleWarning(r, jQueryObj);
		toggleHelp(r, jQueryObj.next());
		return r;
	};
	var isNotEqualVal = function(jQueryObj1, jQueryObj2) {
		var r = jQueryObj1.val() !== jQueryObj2.val();
		toggleWarning(r, jQueryObj2);
		toggleHelp(r, $('#helpToDup'));
		return r;
	};
	// Validates the form elements before sending the AJAX request
	form.on('ajax:before', function(e){
		var target = e.target;
		var date = form.find('[name="date"]')
		var amount = form.find('[name="amount"]');
		var _from = form.find('[name="from"]');
		var to = form.find('[name="to"]');
		atSuccess.hide();
		atError.hide();
		return isDate(date) &&
			isGreaterThanZero(amount) &&
			isNotEmpty(_from) &&
			isNotEmpty(to) &&
			isNotEqualVal(_from, to);
	});
	// Updates success alert with the result obtained
	form.on('ajax:success', function(e, data, status, xhr) {
		var to = form.find('[name="to"]');
		atSuccess.html(data.result+' '+to.val()).show();
	});
	// Updates warning alert with the detailed error message, if any
	form.on('ajax:error', function(e, xhr, status) {
		if (xhr.responseJSON) {
			atError.html(xhr.responseJSON.detail).show();
		}
		else {
			atError.html(status).show();
		}
	});
});