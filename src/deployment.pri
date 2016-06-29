#unix:!android {
#    isEmpty(target.path) {
#        qnx {
#            target.path = /tmp/$${TARGET}/bin
#        } else {
#            #target.path = /opt/$${TARGET}/bin
#            target.path = $$PWD/../release
#        }
#        export(target.path)
#    }
#    INSTALLS += target
#}

#export(INSTALLS)

