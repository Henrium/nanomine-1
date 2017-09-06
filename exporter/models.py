################################################################################
#
# File Name: models.py
# Application: exporter
# Purpose:
#
# Author: Sharief Youssef
#         sharief.youssef@nist.gov
#
#         Guillaume SOUSA AMARAL
#         guillaume.sousa@nist.gov
#
#         Pierre Francois RIGODIAT
#		  pierre-francois.rigodiat@nist.gov
#
# Sponsor: National Institute of Standards and Technology (NIST)
#
################################################################################

from abc import ABCMeta, abstractmethod
import os
import uuid
import hashlib
import sha3


class Exporter(object):
    """
    Export data to different formats
    This class contains 2 principal methods:
        - transform: transforms a XML to another format
        - transformAndZIp: transforms all XML given in parameter and Zip all
    """
    __metaclass__ = ABCMeta

    def __init__(self):
        """
            Method: Initialisation.
            Outputs: -
        """
        self.name = "Results"
        self.extension = ".xml"

    def _transformAndZip(self, instance, results, zip):
        """
            Method: Calls the specific transform method of the object over all results and creates a Zip file
            Outputs: Zip file in parameter
        """
        resultsTransform = self._transform(results)
        is_blob = self.extension == ".blob"

        for result in resultsTransform:
            base_path = "{!s}".format(result['title'])
            if not is_blob:
                # We remove the extension
                title = result['title'] + self.extension
                path = "{!s}/{!s}".format(base_path, title)
                zip.writestr(path, result['content'].encode('utf-8'))
            else:
                # May have several blob
                for blob in result['content']:
                    path = "{!s}/{!s}".format(base_path, blob['blob_name'])
                    zip.writestr(path, blob['blob_file'])

        # fix for Linux zip files read in Windows
        for xmlFile in zip.filelist:
            xmlFile.create_system = 0

    @staticmethod
    def get_title_document(document_name, content):
        # generate sha
        sha = Exporter.get_sha(content)
        # delete the extension of the document name
        document_name = os.path.splitext(document_name)[0]
        return "{!s}.{!s}".format(document_name, sha)

    @staticmethod
    def get_sha(content):
        # new instance of sha3
        hash_result = hashlib.sha3_512()
        # if unicode, the content must be encoded
        if isinstance(content, unicode):
            content = content.encode('utf-8')
        hash_result.update(content)
        # take first 8 letters
        return hash_result.hexdigest()[0:8]

    @abstractmethod
    def _transform(self, results):
        """
            Method: Get the convert data
            Outputs: returns the data converted
        """
        raise NotImplementedError("This method is not implemented.")

