import sys

from PyQt4.QtCore import *
from PyQt4.QtGui import *

from ngw_api.core.ngw_connection_settings import NGWConnectionSettings
from ngw_api.qt.qt_ngw_resource_model_new import QNGWResourcesModel

app = QApplication(sys.argv)

widget = QTreeView()

t = QThread()

model = QNGWResourcesModel(
    NGWConnectionSettings(
        sys.argv[1],
        sys.argv[2],
        sys.argv[3],
        sys.argv[4]
    )
)

model.moveToThread(t)

# t.start()

widget.setModel(model)
widget.show()

sys.exit(app.exec_())
