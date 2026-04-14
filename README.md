# Flowing Information
FLIN(Flowing Information)是一个根据GPL-3.0开源的音游

## 玩法
`Z,C,B,M`四个键(你也可以用`D,F,J,K`)分别对应第`1,2,3,4`条轨道,<br>
按下对应建消除对应位置的音符
（好吧，先写这么多）

键分3种:
### Tap (Blue Note)
单击按键即可<br>
有4种判定: `Perfect`, `Great`, `Good`, `Miss`

### Drag (Yellow Note)
按键按下即可<br>
有2种判定: `Perfect`, `Miss`

### Double (Red Note)
单击按键后, 你需要再按下`Space`, `X`, `V`, or `N`才可以避免`Miss`,<br>
它分两次判断, 第一次的判定是独立的, 第二次的判断不会加Score和Combo,<br>
但是第二次可能会使你断连

有7种判定: `Perfect / Miss`, `Great / Miss`, `Good / Miss`,<br>
`Perfect`, `Great`, `Good`, `Miss`

(带有Miss的都会断连)

## 写铺子
### 格式
```json
[
	{"time": <Note出现的时间>, "lane": <轨道>, "type": <blue / yellow / red>},
	{"time": <Note出现的时间>, "lane": <轨道>, "type": <blue / yellow / red>},
	{"time": <Note出现的时间>, "lane": <轨道>, "type": <blue / yellow / red>},
	...
]
```
