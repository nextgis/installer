try:
    from ..requests import get
except:
    from requests import get

from .default import DEFAULT_URL


class ApiClient:
    VERSION = 0

    def __init__(self, endpoint_url=DEFAULT_URL):
        self.endpoint_url = endpoint_url

    @property
    def base_url(self):
        return '%s/api/v%s/' % (self.endpoint_url, self.VERSION)

    def full_url(self, sub_url):
        return self.base_url + sub_url

    def _get_json(self, url, params=None):
        response = get(url, params, verify=False)
        return response.json()

    def _get_content(self, url, params=None):
        response = get(url, params, stream=True, verify=False)
        return response.content
