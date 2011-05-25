FileIsBinary(_filePath)
{
    FileGetSize, data_size, %_filePath%
    FileRead, data, %_filePath%
    return (data_size != StrLen(data))
}