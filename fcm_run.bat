@rem -----------------------------------------------------------------------
@rem --- FCM_SCRIPT - Based on the works of http://honeylab.hatenablog.jp/ -
@rem -----------------------------------------------------------------------

@echo Appending fcm_script.sh to filesystem ...
@tool_gzip.exe -dfkq up5rootfs.cpio.gz
@copy /Y fcm_script.sh fcm_script_run >NUL
@tool_dos2unix.exe fcm_script_run >NUL
@echo fcm_script_run|tool_cpio.exe --quiet -oc >>up5rootfs.cpio
@IF %ERRORLEVEL% == 1 goto cleanup:
@del fcm_script_run >NUL 2>NUL

@echo.
@echo Building uboot image ...
@del up5rootfs.cpio.script.gz >NUL 2>NUL
@tool_gzip.exe -9S .script.gz up5rootfs.cpio
@tool_mkimage.exe -A arm -O linux -T ramdisk -C none -a 0x00000000 -n "NESMini CFW" -d up5rootfs.cpio.script.gz up5rootfs.cpio.script.uboot >NUL
@IF %ERRORLEVEL% == 1 goto cleanup:
@del up5rootfs.cpio.script.gz >NUL 2>NUL

@echo.
@echo Checking for fel device ...
@tool_sunxi-fel.exe ver >NUL 2>NUL
@IF %ERRORLEVEL% == 1 goto retryfel:
@goto donefel:

:retryfel
@echo While holding reset plug in the USB cable
@PING 1.1.1.1 -n 1 -w 500 >NUL
@tool_sunxi-fel.exe ver >NUL 2>NUL
@IF %ERRORLEVEL% == 1 goto retryfel:

:donefel
@echo.
@echo OK - Starting write ...
@tool_sunxi-fel.exe uboot up1sunxi.bin write-with-progress 0x43000000 up2script.bin write-with-progress 0x42000000 up3image.bin write-with-progress 0x43100000 up4bootscr.bin write-with-progress 0x43300000 up5rootfs.cpio.script.uboot
@IF %ERRORLEVEL% == 1 goto cleanup:

@echo.
@echo DONE - Check HDMI for script output
@echo.

:cleanup
@del fcm_script_run >NUL 2>NUL
@del up5rootfs.cpio.script.gz >NUL 2>NUL
@del up5rootfs.cpio.script.uboot >NUL 2>NUL

@pause
