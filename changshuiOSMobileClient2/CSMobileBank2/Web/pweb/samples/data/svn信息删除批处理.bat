//----------------以下是bat代码-----------------------------
@echo On
@Rem 删除SVN版本控制目录
@PROMPT [Com]

@for /r . %%a in (.) do @if exist "%%a\.svn" rd /s /q "%%a\.svn"
@Rem for /r . %%a in (.) do @if exist "%%a\.svn" @echo "%%a\.svn"

@echo Mission Completed.
@pause

//--------------分割符里面的代码------------------------------------------


生成一个BAT文件放到你要清理的文件夹，执行bat就清理文件夹下的.svn文件

//+++++++++++++++++更新
删除SVN/CVS目录的bat脚本
@echo On
@Rem 删除SVN版本控制目录
@PROMPT [Com]
@for /r . %%a in (.) do @if exist "%%a\.svn" rd /s /q "%%a\.svn"
@Rem for /r . %%a in (.) do @if exist "%%a\.svn" @echo "%%a\.svn"
@echo Mission Completed.
@pause
@echo On
@Rem 删除CVS版本控制目录
@PROMPT [Com]#
@for /r . %%a in (.) do @if exist "%%a\CVS" rd /s /q "%%a\CVS"
@Rem for /r . %%a in (.) do @if exist "%%a\CVS" @echo "%%a\CVS"
@echo Mission Completed.
@pause