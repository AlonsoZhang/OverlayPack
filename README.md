# OverlayPack

部门程式自动化打包工具，辅助完成一系列比对检查功能，并生成相关邮件。

### 打包步骤
1. 打开 OverlayPack tool。

	![overlaypack](http://www.zhangwu.tech/20180508081738_9KAZK0_overlaypack-1.jpeg)

2. 右下角默认为最新的AElimits，点击下拉菜单有各个历史版本可供选择。
3. 拖动 XXX_AE_Mix.app到窗口任意位置。
(App name format: XX_AE_xxx.app)

	![overlaypack](http://www.zhangwu.tech/20180508081738_qx4bHD_overlaypack-2.jpeg)
	
4. 选择需要打包的站别。

	![overlaypack](http://www.zhangwu.tech/20180508081738_npYv5B_overlaypack-3.jpeg)
	
5. 点击ZIP的图标进行打包。完成后会将所选的Overlay放置在桌面一个随机三位数命名的文件夹内。

	![overlaypack](http://www.zhangwu.tech/20180508081738_ZF0s1t_overlaypack-4.jpeg)
	
6. 点击右边上传图标，输入自己的邮箱地址并发送。
	![overlaypack](http://www.zhangwu.tech/20180508081738_pr1Qj3_overlaypack-5.jpeg)
	
7. 打开邮件，将[Uncheck]改成offline验证情况。

8. 根据需求编辑邮件发送给Sum。

	![overlaypack](http://www.zhangwu.tech/20180508081738_8vpN0g_overlaypack-6.jpeg)

### 比对功能

1. 打包前会自动进行比对的工作，或者点击中间比对图标可执行单独比对。

2. 比对会先比对两组数组个数。

	![overlaypack](http://www.zhangwu.tech/20180508081738_hTSurW_overlaypack-7.jpeg)

3. 有任何不同之处会标红。

4. 括号内为AE Limits标准值。

	![overlaypack](http://www.zhangwu.tech/20180508081738_Fw5Nvm_overlaypack-8.jpeg)

### 注意事项

1. 打包Overlay会做一系列的基本检查。
DoDebug、Version、ReleaseNote、****等。
2. 每版AE limits的plist在桌面上生成一次。
3. 打包时在桌面生成的文件夹名称为三位数的随机数。
4. 打包时contents文件夹会被隐藏。
5. 打包前会进行AE limits的比对。
6. 有任何异常发生均不会完成最后的打包。
7. /shared为共享文件夹。