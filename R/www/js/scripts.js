
function showUploadError(message) {
	$('#apDialog #apErrorBox').removeClass('hidden');
	$('#apDialog #apErrorBox #message').text(message);
}

$(function() {
	$('#apDialog').dialog({
		title: 'Analysis Parameters',
		autoOpen: true,
		width: 540,
		modal: true,
		show: 'fade',
		hide: 'fade',
		position: { my: "center", at: "top", of: window },
		create: function(event, ui) {
			$('#gcmsFactor').prop('disabled', true);
			$('#gcmsPhenoFile').change(function() {
				var flag = $(this).val() === '';
				console.log(flag);
				$('#gcmsFactor').prop('disabled', flag);
			})
		},
		buttons: {
			'Run analysis': function() {
				var selectedTab = $('#apTabset li.active').text().trim();
				
				// Validate inputs
				if(selectedTab === 'GC-MS (RIKEN format)') {
					if($('#gcmsRawFile').val() === '') {
						showUploadError('Please choose a raw data file');
						return
					}
					if($('#gcmsPhenoFile').val() === '') {
						showUploadError('Please choose a phenodata file');
						return
					}
					if($('#gcmsFactor').val() === null) {
						showUploadError('Please choose at least one factor');
						return
					}
				}
				else if(selectedTab === 'Generic') {
					if($('#genericRawFile1').val() === '') {
						showUploadError('Please choose a raw data file for dataset 1');
						return
					}
					if($('#genericPhenoFile1').val() === '') {
						showUploadError('Please choose a phenodata file for dataset 1');
						return
					}
					if($('#genericRawFile2').val() === '') {
						showUploadError('Please choose a raw data file for dataset 2');
						return
					}
					if($('#genericPhenoFile2').val() === '') {
						showUploadError('Please choose a phenodata file for dataset 2');
						return
					}
				}

				$('#apConfig').val(selectedTab).change();
				$(this).dialog('close');
			},
			Cancel: function() {
				$(this).dialog('close');
			}
		},
	});

	$('#gcmsFactor, #genericId1, #genericSyn1, #genericId2, #genericSyn2').prop('disabled', true);

	$('#openApEditor').button().click(function() {
		$('#apDialog .errorbox').addClass('hidden');
		$('#apDialog').dialog('open');
	});

	// Hack: Render dialog(s) in the background
	function forceDialogRender(dialogName) {
		// CSS Hide while rendering
		$(dialogName).parent().addClass('invisible');
		$('.ui-widget-overlay').addClass('invisible');

		// Close dialogName and CSS unhide after timeout
		setTimeout(function() {
			$(dialogName).dialog('close');
			$(dialogName).parent().removeClass('invisible');
			$('.ui-widget-overlay').removeClass('invisible');
		}, 10);
	}
	forceDialogRender('#apDialog');
})