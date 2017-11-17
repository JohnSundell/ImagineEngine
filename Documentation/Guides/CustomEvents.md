# Custom Events

You can easily extend Imagine Engine's default suite of events with your own. This is super useful for communicating between different parts of your game code, such as between a scene and a plugin.

## Starting point

Let's say that we're building an asteroid game, and each time an asteroid is added to the scene, we want to trigger a custom event. To add an asteroid every 10 seconds, we use the `Timeline` API in our scene, like this:

```swift
class AsteroidScene: Scene {
    override func setup() {
        timeline.repeat(withInterval: 10, using: self) { scene in
            let asteroid = Actor(textureNamed: "Asteroid")
            asteroid.position = scene.center
            scene.add(asteroid)
        }
    }
}
```

## Defining an event

To be able to trigger a custom event, we have to start by defining it. To do that, we start by adding an extension on `SceneEventCollection` and define our event as a property. Then all we have to do is to call `makeEvent()` from within that property definition, like this:

```swift
extension SceneEventCollection {
    var asteroidAdded: Event<Scene, Actor> {
        return makeEvent()
    }
}
```

*If you wanted to add a custom event for actors, you'd instead use `ActorEventCollection` as the class you're extending.*

## Triggering event

You can now observe and trigger the event just like a built-in one. For example, right after we add an asteroid to the scene we can simply add this line of code to trigger our new custom event:

```swift
scene.events.asteroidAdded.trigger(with: asteroid)
```

We can now observe our new event to drive our game logic, for example to display a warning text whenever a new asteroid is incoming:

```swift
scene.events.asteroidAdded.observe { scene, asteroid in
    let label = Label(text: "Warning! Incoming asteroid!")
    label.position = scene.center
    scene.add(label)
}
```