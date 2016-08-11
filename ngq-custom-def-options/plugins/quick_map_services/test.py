from .qms_external_api_python.client import Client


def test(n):
    for i in range(0, n):
        searcher = Client()
        results = searcher.search_geoservices("Nasa")
        print "%d: %s" % (i, str(results))
