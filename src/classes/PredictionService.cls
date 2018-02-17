public with sharing class PredictionService {

	class LamdbaResponse {
		Decimal result;
	}

	static String ENDPOINT = 'https://jykbauxt22.execute-api.us-west-2.amazonaws.com/test/python-http';

	static Map<String, String> fieldMap = new Map<String, String> {
		'Borough__c' => 'borough',
		'Neighborhood__c' => 'neighborhood',
		'Accommodates__c' => 'accommodates',
		'Property_Type__c' => 'property_type',
		'Latitude__c' => 'latitude',
		'Longitude__c' => 'longitude'
	};

	public static Map<String, Object> getMapping(Id targetId) {
		String q = 'SELECT ';
		q += String.join(new List<String>(fieldMap.keySet()), ', ');
		q += ' FROM ' + targetId.getSobjectType().getDescribe().getName();
		q += ' WHERE Id = \'' + targetId + '\'';

		SObject record = Database.query(q);

		Map<String, Object> r = new Map<String, Object>();

		for (String fieldName : fieldMap.keySet()) {
			r.put(fieldMap.get(fieldName), record.get(fieldName));
		}
		return r;
	}

	public static void predict(Id targetId) {
		Map<String, Object> mapping = getMapping(targetId);

		HttpRequest req = new HttpRequest();
		req.setTimeout(5000);
		req.setEndpoint(ENDPOINT);
		req.setMethod('POST');
		req.setBody(JSON.serialize(mapping));
	
		Http http = new Http();
		HttpResponse res = http.send(req);

		system.debug(res.getBody());

		if (res.getStatusCode() == 200) {
			populatePrediction(targetId, res.getBody());
		} else {

		}
	}

	public static void populatePrediction(Id targetId, String res) {
		LamdbaResponse r = (LamdbaResponse) JSON.deserialize(res, LamdbaResponse.class);
		Listing__c record = new Listing__c(Id = targetId);
		record.Price_Suggestion__c = r.result;
		update record;
	}
}