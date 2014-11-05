FILE(GLOB datafiles *.kvtml)

install( FILES ${datafiles}  DESTINATION  ${DATA_INSTALL_DIR}/kvtml/gl )
install( FILES gl.txt DESTINATION ${DATA_INSTALL_DIR}/khangman )
