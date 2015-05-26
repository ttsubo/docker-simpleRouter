import json



def get_json_from_dict(data):
	return json.dumps(data)


def merge_dicts(d1, d2):
	return dict(d1.items() + d2.items())


def json_to_string(data):
	return json.JSONEncoder().encode(data)
