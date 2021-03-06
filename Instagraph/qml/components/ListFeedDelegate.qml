import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import QtMultimedia 5.6
import Ubuntu.Components.Popups 1.3
import Ubuntu.Content 1.3
import Ubuntu.DownloadManager 1.2

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

ListItem {
    divider.visible: false
    height: suggestions == true ? (suggestions_column_loader.height + units.gu(4)) : (storiesFeedTray == true ? (storiesfeedtray_column_loader.height) : (entry_column_loader.height + units.gu(4)))

    property var last_deleted_media
    property var thismodel
    property var thiscommentsmodel
    property var thissuggestionsmodel

    Component {
        id: popoverComponent
        ActionSelectionPopover {
            id: popoverElement
            delegate: ListItem {
                visible: action.visible
                height: action.visible ? entry_column.height + units.gu(4) : 0

                Column {
                    id: entry_column
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        topMargin: units.gu(2)
                    }
                    spacing: units.gu(1)
                    width: parent.width - units.gu(4)

                    Label {
                        text: action.text
                        font.weight: Font.DemiBold
                        wrapMode: Text.WordWrap
                        textFormat: Text.RichText
                    }
                }
            }
            actions: ActionList {
                  Action {
                      visible: my_usernameId == user.pk
                      enabled: my_usernameId == user.pk
                      text: i18n.tr("Edit")
                      onTriggered: {
                          PopupUtils.close(popoverElement);
                          pageStack.push(Qt.resolvedUrl("../ui/EditMediaPage.qml"), {mediaId: id});
                      }
                  }
                  Action {
                      visible: my_usernameId == user.pk
                      enabled: my_usernameId == user.pk
                      text: i18n.tr("Delete")
                      onTriggered: {
                          last_deleted_media = index
                          instagram.deleteMedia(id);
                      }
                  }
                  Action {
                      visible: photo_of_you
                      enabled: photo_of_you
                      text: i18n.tr("Remove Tag")
                      onTriggered: {
                          last_deleted_media = index
                          instagram.removeSelftag(id);
                      }
                  }
                  Action {
                      visible: !user.is_private && code
                      enabled: !user.is_private && code
                      text: i18n.tr("Copy Share URL")
                      onTriggered: {
                          var share_url = "https://instagram.com/p/"+code;
                          Clipboard.push(share_url);
                          PopupUtils.close(popoverElement);
                      }
                  }
            }

            Connections {
                target: instagram
                onMediaDeleted: {
                    if (index == last_deleted_media) {
                        var data = JSON.parse(answer);
                        if (data.did_delete) {
                            thismodel.remove(index)
                            if (thismodel.count == 0) {
                                pageStack.pop();
                            }
                        }
                    }
                }
                onRemoveSelftagDone: {
                    if (index == last_deleted_media) {
                        var data = JSON.parse(answer);
                        if (data.status == "ok") {
                            thismodel.remove(index)
                            if (thismodel.count == 0) {
                                pageStack.pop();
                            }
                        }
                    }
                }
            }
        }
    }

    Loader {
        id: storiesfeedtray_column_loader
        width: parent.width
        height: width/5 + units.gu(3)
        visible: storiesFeedTray == true
        active: storiesFeedTray == true

        sourceComponent: StoriesTray {
            width: parent.width
            height: parent.height
            anchors {
                fill: parent
            }
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
        }
        height: suggestions_column_loader.height + units.gu(6)
        color: "#fbfbfb"
        visible: suggestions == true

        Loader {
            id: suggestions_column_loader
            width: parent.width
            anchors {
                left: parent.left
                leftMargin: units.gu(1)
                right: parent.right
                rightMargin: units.gu(1)
                top: parent.top
                topMargin: units.gu(1)
            }
            visible: suggestions == true
            active: suggestions == true

            sourceComponent: Column {
                id: suggestions_column
                width: parent.width
                spacing: units.gu(2)

                ListItem {
                    height: suggestionsHeaderRow.height
                    divider.visible: false

                    Row {
                        id: suggestionsHeaderRow
                        width: parent.width
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(1)
                            right: parent.right
                            rightMargin: units.gu(1)
                        }
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            text: i18n.tr("Suggestions for You")
                            width: parent.width - seeAllSuggestionsLink.width
                            wrapMode: Text.WordWrap
                            font.weight: Font.DemiBold
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            id: seeAllSuggestionsLink
                            text: i18n.tr("See All")
                            color: "#275A84"
                            wrapMode: Text.WordWrap
                            font.weight: Font.DemiBold
                            anchors.verticalCenter: parent.verticalCenter

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    pageStack.push(Qt.resolvedUrl("../ui/SuggestionsPage.qml"));
                                }
                            }
                        }
                    }
                }

                SuggestionsSlider {
                    id: suggestionsSlider
                    width: parent.width
                    height: units.gu(15)
                    model: homeSuggestionsModel
                }
            }
        }
    }

    Loader {
        id: entry_column_loader
        width: parent.width
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
        }
        visible: suggestions != true && storiesFeedTray != true
        active: suggestions != true && storiesFeedTray != true

        sourceComponent: Column {
            id: entry_column
            spacing: units.gu(1)
            width: parent.width

            Item {
                width: parent.width
                height: units.gu(0.1)
            }

            Row {
                spacing: units.gu(1)
                width: parent.width
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                Item {
                    width: units.gu(5)
                    height: width

                    CircleImage {
                        id: feed_user_profile_image
                        width: parent.width
                        height: width
                        source: typeof user != 'undefined' && typeof user.profile_pic_url != 'undefined' ? user.profile_pic_url : "../images/not_found_user.jpg"
                    }

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameString: user.username});
                        }
                    }
                }

                Column {
                    spacing: units.gu(0.2)
                    width: parent.width - units.gu(9)
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }

                    Label {
                        text: typeof user != 'undefined' && typeof user.username != 'undefined' ? user.username : ''
                        font.weight: Font.DemiBold
                        wrapMode: Text.WordWrap

                        MouseArea {
                            anchors {
                                fill: parent
                            }
                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameString: user.username});
                            }
                        }
                    }

                    Label {
                        text: typeof location != 'undefined' && typeof location.name != 'undefined' ? location.name : ''
                        fontSize: "medium"
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                    }
                }

                Icon {
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    width: units.gu(2)
                    height: width
                    name: "down"
                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        onClicked: {
                            if (my_usernameId == user.pk || photo_of_you || (!user.is_private && code)) {
                                PopupUtils.open(popoverComponent)
                            }
                        }
                    }
                }
            }

            Component {
                id: singleMedia

                Item {
                    Image {
                        id: feed_image
                        width: parent.width
                        height:parent.width/bestImage.width*bestImage.height
                        fillMode: Image.PreserveAspectCrop
                        source: bestImage.url
                        sourceSize: Qt.size(width,height)
                        asynchronous: true
                        cache: true // maybe false
                        smooth: false

                        layer.enabled: status != Image.Ready
                        layer.effect: Rectangle {
                            anchors.fill: parent
                            color: "#efefef"
                        }
                    }

                    MediaPlayer {
                        id: player
                        source: video_url
                        autoLoad: false
                        autoPlay: false
                        loops: MediaPlayer.Infinite
                    }
                    VideoOutput {
                        id: videoOutput
                        source: player
                        fillMode: VideoOutput.PreserveAspectCrop
                        width: 800
                        height: 600
                        anchors.fill: parent
                        visible: media_type == 2
                    }

                    Icon {
                        visible: media_type == 2
                        width: units.gu(3)
                        height: width
                        name: "camcorder"
                        color: "#ffffff"
                        anchors {
                            right: parent.right
                            rightMargin: units.gu(2)
                            top: parent.top
                            topMargin: units.gu(2)
                        }
                    }

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        onClicked: {
                            /*if (media_type == 2) {
                                var singleDownload = downloadComponent.createObject(mainView)
                                singleDownload.contentType = ContentType.Videos
                                singleDownload.download(video_url)
                            }*/

                            if (media_type == 2) {
                                console.log(video_url)
                                if (player.playbackState == MediaPlayer.PlayingState) {
                                    player.stop()
                                } else {
                                    player.play()
                                }
                            }
                        }
                        onDoubleClicked: {
                            last_like_id = id;
                            instagram.like(id);
                        }
                    }

                    Connections {
                        target: instagram
                        onLikeDataReady: {
                            if (JSON.parse(answer).status == "ok" && last_like_id == id) {
                                imagelikeicon.color = UbuntuColors.red;
                                imagelikeicon.name = "like";
                            }
                        }
                        onUnLikeDataReady: {
                            if (JSON.parse(answer).status == "ok" && last_like_id == id) {
                                imagelikeicon.color = "";
                                imagelikeicon.name = "unlike";
                            }
                        }
                    }
                }
            }

            Component {
                id: carouselMedia

                Item {
                    CarouselSlider {
                        id: carouselSlider
                        width: parent.width
                        height: parent.height - units.gu(2)
                        model: carousel_media_obj
                    }

                    Row {
                        id: slideIndicator
                        height: units.gu(2)
                        spacing: units.gu(0.5)
                        anchors {
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }

                        Repeater {
                            model: carousel_media_obj
                            delegate: Rectangle {
                                height: units.gu(0.7)
                                width: units.gu(0.7)
                                radius: width/2
                                antialiasing: true
                                anchors.verticalCenter: parent.verticalCenter
                                color: carouselSlider.currentIndex == index ? UbuntuColors.blue : "black"
                                Behavior on color {
                                    ColorAnimation {
                                        duration: UbuntuAnimation.FastDuration
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        property string direction: "None"
                        property real lastX: -1
                        anchors {
                            fill: parent
                        }
                        onClicked: {
                        }
                        onDoubleClicked: {
                            last_like_id = id;
                            instagram.like(id);
                        }

                        onPressed: lastX = mouse.x

                        onReleased: {
                            var diff = mouse.x - lastX
                            if (Math.abs(diff) < units.gu(4)) {
                                return;
                            } else if (diff < 0) {
                                carouselSlider.nextSlide()
                            } else if (diff > 0) {
                                carouselSlider.previousSlide()
                            }
                        }
                    }

                    Connections {
                        target: instagram
                        onLikeDataReady: {
                            if (JSON.parse(answer).status == "ok" && last_like_id == id) {
                                imagelikeicon.color = UbuntuColors.red;
                                imagelikeicon.name = "like";
                            }
                        }
                        onUnLikeDataReady: {
                            if (JSON.parse(answer).status == "ok" && last_like_id == id) {
                                imagelikeicon.color = "";
                                imagelikeicon.name = "unlike";
                            }
                        }
                    }
                }
            }

            Loader {
                property var bestImage: typeof carousel_media_obj != 'undefined' ?
                                            (carousel_media_obj.count > 0 ?
                                                 Helper.getBestImage(carousel_media_obj.get(0).image_versions2.candidates, parent.width) :
                                                 (typeof image_versions2.candidates != 'undefined' ?
                                                      Helper.getBestImage(image_versions2.candidates, parent.width) :
                                                      {"width":0, "height":0, "url":""})) :
                                            {"width":0, "height":0, "url":""}

                width: parent.width
                height: typeof carousel_media_obj != 'undefined' ?
                            (carousel_media_obj.count > 0 ?
                                 ((parent.width/bestImage.width*bestImage.height) + units.gu(2)) :
                                 parent.width/bestImage.width*bestImage.height) :
                            parent.width/bestImage.width*bestImage.height

                sourceComponent: typeof carousel_media_obj != 'undefined' ?
                                     (carousel_media_obj.count > 0 ?
                                          carouselMedia :
                                          singleMedia) :
                                     singleMedia
            }

            Row {
                spacing: units.gu(2.3)
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                Item {
                    width: units.gu(4)
                    height: width

                    Icon {
                        id: imagelikeicon
                        anchors.centerIn: parent
                        width: units.gu(3)
                        height: width
                        name: has_liked == true ? "like" : "unlike"
                        color: has_liked == true ? UbuntuColors.red : "#000000"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (imagelikeicon.name == "unlike") {
                                last_like_id = id;
                                instagram.like(id);
                            } else if (imagelikeicon.name == "like") {
                                last_like_id = id;
                                instagram.unLike(id);
                            }
                        }
                    }
                }

                Item {
                    width: units.gu(4)
                    height: width

                    Icon {
                        anchors.centerIn: parent
                        width: units.gu(3)
                        height: width
                        name: "message"
                        color: "#000000"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../ui/CommentsPage.qml"), {photoId: id, mediaUserId: user.pk});
                        }
                    }
                }

                Item {
                    width: units.gu(4)
                    height: width

                    Icon {
                        anchors.centerIn: parent
                        width: units.gu(3)
                        height: width
                        name: "share"
                        color: "#000000"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../ui/ShareMediaPage.qml"), {mediaId: id, mediaUser: user});
                        }
                    }
                }

                Item {
                    width: units.gu(4)
                    height: width

                    Icon {
                        anchors.centerIn: parent
                        width: units.gu(3)
                        height: width
                        name: "save"
                        color: "#000000"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var singleDownload = downloadComponent.createObject(mainView)
                            singleDownload.contentType = ContentType.Pictures
                            singleDownload.download(image_versions2.candidates[0].url)
                        }
                    }
                }
            }

            Row {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: parent.width
                    height: units.gu(0.17)
                    color: Qt.lighter(UbuntuColors.lightGrey, 1.2)
                }
            }

            Flow {
                visible: typeof like_count != 'undefined' && like_count != 0 ? true : false
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: units.gu(1)

                Icon {
                    width: units.gu(2)
                    height: width
                    name: "like"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../ui/MediaLikersPage.qml"), {photoId: id});
                        }
                    }
                }

                Label {
                    text: like_count + i18n.tr(" likes")
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../ui/MediaLikersPage.qml"), {photoId: id});
                        }
                    }
                }
            }

            Column {
                spacing: units.gu(0.5)
                width: parent.width - units.gu(3)

                Text {
                    visible: typeof caption != 'undefined' && caption.text ? true : false
                    text: typeof caption != 'undefined' && caption.text ? Helper.formatUser(caption.user.username) + ' ' + Helper.formatString(caption.text) : ""
                    wrapMode: Text.WordWrap
                    width: parent.width
                    textFormat: Text.RichText
                    onLinkActivated: {
                        Scripts.linkClick(link)
                    }
                }

                Label {
                    visible: has_more_comments == true ? true : false
                    text: i18n.tr("View all %1 comments").arg(comment_count)
                    color: UbuntuColors.darkGrey
                    wrapMode: Text.WordWrap
                    width: parent.width

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../ui/CommentsPage.qml"), {photoId: id});
                        }
                    }
                }

                Repeater {
                    model: thiscommentsmodel

                    Text {
                        visible: c_image_id == pk && typeof comment != 'undefined' && comment.text ? true : false
                        text: c_image_id == pk && typeof comment != 'undefined' && comment.text ? Helper.formatUser(comment.user.username) + ' ' + Helper.formatString(comment.text) : ""
                        wrapMode: Text.WordWrap
                        width: entry_column.width
                        textFormat: Text.RichText
                        onLinkActivated: {
                            Scripts.linkClick(link)
                        }
                    }
                }
            }

            Column {
                width: parent.width
                spacing: units.gu(1)

                Label {
                    text: Helper.milisecondsToString(taken_at)
                    fontSize: "small"
                    color: UbuntuColors.darkGrey
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
