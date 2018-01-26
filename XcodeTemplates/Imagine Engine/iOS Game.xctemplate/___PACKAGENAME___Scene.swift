import ImagineEngine

// A scene acts as a container for your game objects, much like a view controller
// in an iOS app. You can move between different scene's in a game, so you can
// split your game's menus & levels up into multiple scenes.
final class ___PACKAGENAME___Scene: Scene {
    override func setup() {
        // Actors are the core objects of any game, they represent all movable &
        // scriptable objects - like players, enemies & collectables.
        let actor = Actor()
        actor.backgroundColor = .red
        actor.size = Size(width: 100, height: 100)
        actor.position = center
        add(actor)

        // Actions enable you to move, rotate & scale your game objects over
        // time. You can also define your own actions using the `Action` class
        actor.repeat(RotateAction(delta: .pi * 2, duration: 2))

        // Labels let you easily add text to your game's scenes
        let label = Label(text: "Hello Imagine Engine!")
        label.font = .boldSystemFont(ofSize: 20)
        label.position = center
        add(label)

        // Events let you script your game by reacting to things like user input
        // or when two objects collided. Each game object has an `events` property
        // where you can find all observable events for that object.
        events.clicked.addObserver(actor) { actor in
            func randomColorValue() -> Metric {
                return Metric(arc4random_uniform(101)) / 100
            }

            actor.backgroundColor = Color(
                red: randomColorValue(),
                green: randomColorValue(),
                blue: randomColorValue(),
                alpha: 1
            )
        }
    }
}
