from exporter.builtin.models import Exporter
import lxml.etree as etree
import re
import urllib2


class BLOBExporter(Exporter):
    """
    JSON Exporter. Allows to transform a XML document to JSON file
    """
    def __init__(self):
        self.name = "BLOB"
        self.extension = ".blob"

    def _transform(self, results):
        """
            Method: Implement the abstract method.
            Outputs: Returns a list of results (title, content)
        """
        return_transformation = []
        try:
            for result in results:
                xml = result['content']
                sha = Exporter.get_sha(xml)
                title = self.get_title_document(result['title'], xml)
                if xml != "":
                    try:
                        # Get all url from xml content
                        urls = _get_blob_url_list_from_xml(xml)
                        files = []
                        # Get all blobs from urls
                        for url in urls:
                            try:
                                blob_file = urllib2.urlopen(url)
                                blob_file_read = blob_file.read()
                                blob_name = _get_filename_from_blob(blob_file.info(), blob_file_read, sha)
                                files.append({'blob_name': blob_name, 'blob_file': blob_file_read})
                            except Exception:
                                pass
                        return_transformation.append({'title': title, 'content': files})
                    except etree.ParseError as e:
                        raise
                    except:
                        raise
        except etree.ParseError as e:
            raise
        except:
            raise

        return return_transformation


def _get_blob_url_list_from_xml(xml):
    return re.findall('>(http[s]?:.+/rest/blob\?id=[^<]+)', xml)


def _get_filename_from_blob(blob_file_info, blob_file_read, sha_from_xml):
    for raw in blob_file_info.headers:
        if 'filename' in raw:
            file_names = re.findall("filename=(.+)", raw)
            if len(file_names) > 0:
                sha = Exporter.get_sha(blob_file_read)
                file_name = file_names[0]
                file_name_split = file_name.split('.')
                return_value = file_name_split[0]
                for index in xrange(1, len(file_name_split)):
                    if index == len(file_name_split) - 1:
                        return_value += '.' + sha_from_xml + '.' + sha
                    return_value += '.' + file_name_split[index]
                return return_value.replace('\r', '')
